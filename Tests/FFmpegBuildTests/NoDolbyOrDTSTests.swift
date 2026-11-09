import Testing
import AetherLibavcodec

/// mkolakowski fork (MK Plus): the shipped libavcodec carries no Dolby or DTS
/// decoder and no E-AC-3 encoder. The app decodes AC-3 and E-AC-3 with Apple's
/// AudioToolbox and doesn't decode TrueHD, MLP or DTS; their parsers stay so
/// those tracks are still framed and listed.
struct NoDolbyOrDTSTests {

    @Test("no Dolby or DTS decoder", arguments: [
        AV_CODEC_ID_AC3, AV_CODEC_ID_EAC3, AV_CODEC_ID_TRUEHD, AV_CODEC_ID_MLP, AV_CODEC_ID_DTS,
    ])
    func decoderIsAbsent(_ id: AVCodecID) {
        #expect(avcodec_find_decoder(id) == nil, "\(String(cString: avcodec_get_name(id))) has a decoder")
    }

    @Test("no Dolby encoder", arguments: [AV_CODEC_ID_AC3, AV_CODEC_ID_EAC3])
    func encoderIsAbsent(_ id: AVCodecID) {
        #expect(avcodec_find_encoder(id) == nil, "\(String(cString: avcodec_get_name(id))) has an encoder")
    }

    @Test("their parsers stay", arguments: [AV_CODEC_ID_AC3, AV_CODEC_ID_EAC3, AV_CODEC_ID_MLP, AV_CODEC_ID_DTS])
    func parserIsPresent(_ id: AVCodecID) {
        let parser = av_parser_init(Int32(id.rawValue))
        #expect(parser != nil, "\(String(cString: avcodec_get_name(id))) has no parser")
        av_parser_close(parser)
    }

    @Test("the other audio decoders stay", arguments: [
        AV_CODEC_ID_FLAC, AV_CODEC_ID_OPUS, AV_CODEC_ID_MP3, AV_CODEC_ID_VORBIS, AV_CODEC_ID_ALAC, // AAC: out since 3.5.0-mk2
    ])
    func decoderIsPresent(_ id: AVCodecID) {
        #expect(avcodec_find_decoder(id) != nil, "\(String(cString: avcodec_get_name(id))) has no decoder")
    }
}
