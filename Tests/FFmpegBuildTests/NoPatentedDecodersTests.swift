import Testing
import AetherLibavcodec
import AetherLibavformat

/// mkolakowski fork (MK Plus), 3.5.0-mk2: the shipped libavcodec decodes no patent-encumbered
/// video or audio. MK Plus hands H.264 and HEVC to Apple's VideoToolbox and AAC to AudioToolbox
/// directly, and doesn't play MPEG-4 Part 2, VC-1/WMV, Flash-era video, WMA or AAC-LATM. Their
/// parsers and demuxers stay, so those streams are still found, framed and named.
struct NoPatentedDecodersTests {

    @Test("no H.264, HEVC, MPEG-4 Part 2, VC-1/WMV or Flash video decoder", arguments: [
        "h264", "hevc", "mpeg4", "msmpeg4v1", "msmpeg4v2", "msmpeg4", "h263", "vc1", "wmv1", "wmv2", "wmv3",
        "flv", "vp6", "vp6a", "vp6f",
    ])
    func videoDecoderIsAbsent(_ name: String) {
        #expect(avcodec_find_decoder_by_name(name) == nil, "\(name) has a decoder")
    }

    @Test("no AAC, AAC-LATM or WMA decoder", arguments: [
        "aac", "aac_fixed", "aac_latm", "wmav1", "wmav2", "wmapro", "wmalossless", "wmavoice",
    ])
    func audioDecoderIsAbsent(_ name: String) {
        #expect(avcodec_find_decoder_by_name(name) == nil, "\(name) has a decoder")
    }

    @Test("no decoder for their codec ids either", arguments: [
        AV_CODEC_ID_H264, AV_CODEC_ID_HEVC, AV_CODEC_ID_MPEG4, AV_CODEC_ID_VC1, AV_CODEC_ID_WMV3, AV_CODEC_ID_AAC,
        AV_CODEC_ID_AAC_LATM, AV_CODEC_ID_FLV1, AV_CODEC_ID_MSMPEG4V3,
    ])
    func noDecoderForTheID(_ id: AVCodecID) {
        #expect(avcodec_find_decoder(id) == nil, "\(String(cString: avcodec_get_name(id))) has a decoder")
    }

    @Test("their parsers stay", arguments: [
        AV_CODEC_ID_H264, AV_CODEC_ID_HEVC, AV_CODEC_ID_AAC, AV_CODEC_ID_AAC_LATM, AV_CODEC_ID_MPEG4, AV_CODEC_ID_VC1,
    ])
    func parserIsPresent(_ id: AVCodecID) {
        let parser = av_parser_init(Int32(id.rawValue))
        #expect(parser != nil, "\(String(cString: avcodec_get_name(id))) has no parser")
        av_parser_close(parser)
    }

    @Test("the royalty-free and expired ones stay", arguments: [
        "vp8", "vp9", "av1", "libdav1d", "mpeg2video", "qtrle", "flac", "opus", "vorbis", "mp3", "mp2", "alac",
    ])
    func decoderIsPresent(_ name: String) {
        #expect(avcodec_find_decoder_by_name(name) != nil, "\(name) has no decoder")
    }

    @Test("the demuxers that name those files stay", arguments: ["avi", "asf", "flv", "mpegts", "matroska", "mov"])
    func demuxerIsPresent(_ name: String) {
        #expect(av_find_input_format(name) != nil, "\(name) demuxer missing")
    }
}
