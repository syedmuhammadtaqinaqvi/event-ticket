package com.eventpass.event_ticket

import android.nfc.NdefMessage
import android.nfc.NdefRecord

object TicketNfcPayloadHolder {
    @Volatile
    var payload: String = ""

    @Volatile
    var recordType: String = "text"

    @Volatile
    var mimeType: String = "text/plain"

    fun clear() {
        payload = ""
        recordType = "text"
        mimeType = "text/plain"
    }

    fun applyEntryPayload(rawPayload: String, rawRecordType: String?, rawMimeType: String?) {
        payload = rawPayload
        recordType = rawRecordType?.trim()?.lowercase().takeUnless { it.isNullOrEmpty() } ?: "text"
        mimeType = rawMimeType?.trim().takeUnless { it.isNullOrEmpty() } ?: "text/plain"
    }

    fun ndefMessageBytes(): ByteArray? {
        val text = payload.trim()
        if (text.isEmpty()) return null
        val record = when (recordType) {
            "mime" -> NdefRecord.createMime(mimeType, text.toByteArray(Charsets.UTF_8))
            else -> {
                val lang = "en"
                val langBytes = lang.toByteArray(Charsets.US_ASCII)
                val textBytes = text.toByteArray(Charsets.UTF_8)
                val recordPayload = ByteArray(1 + langBytes.size + textBytes.size)
                recordPayload[0] = langBytes.size.toByte()
                System.arraycopy(langBytes, 0, recordPayload, 1, langBytes.size)
                System.arraycopy(textBytes, 0, recordPayload, 1 + langBytes.size, textBytes.size)
                NdefRecord(
                    NdefRecord.TNF_WELL_KNOWN,
                    NdefRecord.RTD_TEXT,
                    ByteArray(0),
                    recordPayload,
                )
            }
        }
        return NdefMessage(record).toByteArray()
    }
}
