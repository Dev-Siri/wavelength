package com.example.wavelength

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.content.Intent
import android.provider.Settings
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.media.AudioDeviceCallback
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "siri.dev.wavelength/audio_output"
    private val EVENT_CHANNEL = "siri.dev.wavelength/audio_output_events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAllDevices" -> {
                        result.success(getAllAudioDevices(audioManager))
                    }
                    "getCurrentDevice" -> {
                        val (type, _) = getCurrentAudioDevice(audioManager)
                        val name = getActiveDeviceName(audioManager)

                        val resultMap = mapOf(
                            "type" to type,
                            "name" to name
                        )

                        result.success(resultMap)
                    }
                    "openBluetoothSettings" -> {
                        val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                private var callback: AudioDeviceCallback? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    callback = object : AudioDeviceCallback() {
                        override fun onAudioDevicesAdded(addedDevices: Array<AudioDeviceInfo>) {
                            sendUpdate(audioManager, events)
                        }

                        override fun onAudioDevicesRemoved(removedDevices: Array<AudioDeviceInfo>) {
                            sendUpdate(audioManager, events)
                        }
                    }

                    audioManager.registerAudioDeviceCallback(callback!!, null)
                }

                override fun onCancel(arguments: Any?) {
                    callback?.let { audioManager.unregisterAudioDeviceCallback(it) }
                }
            })
    }

    private fun getAllAudioDevices(audioManager: AudioManager): List<Map<String, String>> {
        val devicesList = mutableListOf<Map<String, String>>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
            for (device in devices) {
                // ignore inputs / call-only devices
                if (!device.isSink) continue

                val typeName = when (device.type) {
                    AudioDeviceInfo.TYPE_BLUETOOTH_A2DP -> "bluetooth"
                    AudioDeviceInfo.TYPE_WIRED_HEADSET -> "wiredHeadset"
                    AudioDeviceInfo.TYPE_WIRED_HEADPHONES -> "wiredHeadphones"
                    AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> "speaker"
                    AudioDeviceInfo.TYPE_HDMI -> "hdmi"
                    AudioDeviceInfo.TYPE_USB_DEVICE -> "usbDevice"
                    AudioDeviceInfo.TYPE_USB_HEADSET -> "usbHeadset"
                    AudioDeviceInfo.TYPE_LINE_ANALOG,
                    AudioDeviceInfo.TYPE_LINE_DIGITAL,
                    AudioDeviceInfo.TYPE_FM,
                    AudioDeviceInfo.TYPE_AUX_LINE,
                    AudioDeviceInfo.TYPE_HEARING_AID,
                    AudioDeviceInfo.TYPE_BUS -> "other"
                    else -> null
                }

                typeName?.let {
                    devicesList.add(
                        mapOf(
                            "name" to device.productName.toString(),
                            "type" to it,
                            "id" to device.id.toString()
                        )
                    )
                }
            }
        }

        return devicesList
    }

    private fun sendUpdate(audioManager: AudioManager, events: EventChannel.EventSink?) {
        val (type, _) = getCurrentAudioDevice(audioManager)
        val name = getActiveDeviceName(audioManager)

        events?.success(mapOf(
            "type" to type,
            "name" to name
        ))
    }

    private fun getActiveDeviceName(audioManager: AudioManager): String {
        val (activeType, _) = getCurrentAudioDevice(audioManager)

        if (activeType == "speaker") {
            return "This phone"
        }

        val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)

        val device = devices.firstOrNull {
            if (!it.isSink) return@firstOrNull false

            when (activeType) {
                "bluetooth" -> it.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
                               it.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO

                "wired" -> it.type == AudioDeviceInfo.TYPE_WIRED_HEADSET ||
                           it.type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES

                else -> false
            }
        }

        return device?.productName?.toString() ?: when (activeType) {
            "bluetooth" -> "Bluetooth Device"
            "wired" -> "Wired Headphones"
            else -> "Unknown Device"
        }
    }

    private fun getCurrentAudioDevice(audioManager: AudioManager): Pair<String, String> {
        return when {
            audioManager.isBluetoothA2dpOn -> {
                "bluetooth" to "Bluetooth Audio"
            }
            audioManager.isWiredHeadsetOn -> {
                "wired" to "Wired Headphones"
            }
            audioManager.isSpeakerphoneOn -> {
                "speaker" to "Speaker"
            }
            else -> {
                "speaker" to "Device Speaker"
            }
        }
    }
}
