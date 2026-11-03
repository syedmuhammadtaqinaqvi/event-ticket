package com.eventpass.event_ticket

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.util.Log

/**
 * Host card emulation — Type 4 NDEF tag with rotating door payload as Text record.
 */
class TicketHceService : HostApduService() {

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        return try {
            TicketNfcType4Protocol.processApdu(commandApdu)
        } catch (e: Exception) {
            Log.w(TAG, "APDU error", e)
            byteArrayOf(0x6F.toByte(), 0x00)
        }
    }

    override fun onDeactivated(reason: Int) {
        TicketNfcType4Protocol.reset()
    }

    companion object {
        private const val TAG = "TicketHceService"
    }
}
