package com.eventpass.event_ticket

/**
 * Minimal NFC Forum Type 4 Tag (NDEF) HCE responses for door / Web NFC readers.
 */
object TicketNfcType4Protocol {

    private enum class SelectedFile { NONE, CC, NDEF }

    private var selectedFile = SelectedFile.NONE

    private val ccFile = byteArrayOf(
        0x00, 0x0f,
        0x20,
        0x00, 0x3b,
        0x00, 0x34,
        0x04, 0x06,
        0xe1.toByte(), 0x04, 0x00, 0xff.toByte(), 0x00, 0x00,
    )

    private val ndefAid = byteArrayOf(
        0xD2.toByte(), 0x76.toByte(), 0x00.toByte(), 0x00.toByte(),
        0x85.toByte(), 0x01.toByte(), 0x01.toByte(),
    )

    fun processApdu(apdu: ByteArray?): ByteArray {
        if (apdu == null || apdu.size < 4) return unknown()

        // SELECT
        if (apdu[1] == 0xA4.toByte()) {
            if (selectByAid(apdu)) {
                selectedFile = SelectedFile.NONE
                return ok()
            }
            val fileId = selectFileId(apdu)
            when (fileId) {
                0xE103 -> {
                    selectedFile = SelectedFile.CC
                    return ok()
                }
                0xE104 -> {
                    selectedFile = SelectedFile.NDEF
                    return ok()
                }
            }
        }

        // READ BINARY
        if (apdu[1] == 0xB0.toByte()) {
            val offset = ((apdu[2].toInt() and 0xFF) shl 8) or (apdu[3].toInt() and 0xFF)
            val le = readLe(apdu)
            return when (selectedFile) {
                SelectedFile.CC -> readChunk(ccFile, offset, le)
                SelectedFile.NDEF -> {
                    val ndefFile = buildNdefFile() ?: return unknown()
                    readChunk(ndefFile, offset, le)
                }
                SelectedFile.NONE -> unknown()
            }
        }

        return unknown()
    }

    fun reset() {
        selectedFile = SelectedFile.NONE
    }

    private fun selectByAid(apdu: ByteArray): Boolean {
        if (apdu.size < 5) return false
        if (apdu[0] != 0x00.toByte() || apdu[1] != 0xA4.toByte()) return false
        val lc = apdu[4].toInt() and 0xFF
        if (apdu.size < 5 + lc) return false
        if (lc != ndefAid.size) return false
        for (i in ndefAid.indices) {
            if (apdu[5 + i] != ndefAid[i]) return false
        }
        return true
    }

    private fun selectFileId(apdu: ByteArray): Int? {
        if (apdu.size < 7) return null
        val p1 = apdu[2].toInt() and 0xFF
        val p2 = apdu[3].toInt() and 0xFF
        if (p2 != 0x0C) return null
        if (p1 != 0x00 && p1 != 0x02) return null
        val lc = apdu[4].toInt() and 0xFF
        if (lc != 2 || apdu.size < 7) return null
        return ((apdu[5].toInt() and 0xFF) shl 8) or (apdu[6].toInt() and 0xFF)
    }

    private fun readLe(apdu: ByteArray): Int {
        return when {
            apdu.size >= 5 && apdu[4].toInt() != 0 -> apdu[4].toInt() and 0xFF
            apdu.size >= 6 -> apdu[5].toInt() and 0xFF
            else -> 256
        }
    }

    private fun buildNdefFile(): ByteArray? {
        val message = TicketNfcPayloadHolder.ndefMessageBytes() ?: return null
        val len = message.size
        if (len > 0xFFFF) return null
        return byteArrayOf(
            ((len shr 8) and 0xFF).toByte(),
            (len and 0xFF).toByte(),
        ) + message
    }

    private fun readChunk(data: ByteArray, offset: Int, le: Int): ByteArray {
        if (offset < 0 || offset >= data.size) return unknown()
        val end = minOf(data.size, offset + if (le == 0) data.size - offset else le)
        val chunk = data.copyOfRange(offset, end)
        return chunk + ok()
    }

    private fun ok(): ByteArray = byteArrayOf(0x90.toByte(), 0x00)

    private fun unknown(): ByteArray = byteArrayOf(0x6A.toByte(), 0x82.toByte())
}
