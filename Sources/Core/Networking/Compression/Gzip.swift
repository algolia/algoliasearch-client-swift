//
//  Gzip.swift
//
//
//  Created by Algolia on 16/02/2024.
//

// This has been partly inspired by jp1024/GzipSwift, which is not compatible with the latest XCode version anymore.

import Foundation
import zlib

public extension Data {
    func gzip() throws -> Data? {
        var gzipData = Data()

        // GZip header
        let header: [UInt8] = [0x1F, 0x8B, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03]
        gzipData.append(Data(header))

        // Deflate data
        guard let deflatedBody = try self.compress() else {
            return nil
        }
        gzipData.append(deflatedBody)

        // Calculate and append CRC32 checksum (little-endian)
        let crc32 = self.computeChecksum()
        gzipData.append(Data([
            UInt8(crc32 & 0xFF),
            UInt8((crc32 >> 8) & 0xFF),
            UInt8((crc32 >> 16) & 0xFF),
            UInt8((crc32 >> 24) & 0xFF),
        ]))

        // Append uncompressed size (little-endian)
        let uncompressedSize = UInt32(self.count)
        gzipData.append(Data([
            UInt8(uncompressedSize & 0xFF),
            UInt8((uncompressedSize >> 8) & 0xFF),
            UInt8((uncompressedSize >> 16) & 0xFF),
            UInt8((uncompressedSize >> 24) & 0xFF),
        ]))

        return gzipData
    }

    func compress() throws -> Data? {
        let chunkSize = 4096
        let compressionLevel: Int32 = Z_DEFAULT_COMPRESSION

        // init the stream
        var stream = z_stream()
        var result = deflateInit2_(
            &stream,
            compressionLevel,
            Z_DEFLATED,
            -MAX_WBITS,
            MAX_MEM_LEVEL,
            Z_DEFAULT_STRATEGY,
            ZLIB_VERSION,
            Int32(MemoryLayout<z_stream>.size)
        )
        // check for init errors
        guard result == Z_OK else {
            throw AlgoliaError.runtimeError("Unable to init compression stream: \(result)")
        }
        // defer clean up
        defer {
            deflateEnd(&stream)
        }

        // loop over buffers
        var compressedData = Data(capacity: chunkSize)
        repeat {
            if Int(stream.total_out) >= compressedData.count {
                compressedData.count += chunkSize
            }

            let inputCount = self.count
            let outputCount = compressedData.count

            self.withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
                stream
                    .next_in = UnsafeMutablePointer<Bytef>(
                        mutating: inputPointer.bindMemory(to: Bytef.self)
                            .baseAddress!
                    ).advanced(by: Int(stream.total_in))
                stream.avail_in = uInt(inputCount) - uInt(stream.total_in)

                compressedData.withUnsafeMutableBytes { (outputPointer: UnsafeMutableRawBufferPointer) in
                    stream.next_out = outputPointer.bindMemory(to: Bytef.self).baseAddress!
                        .advanced(by: Int(stream.total_out))
                    stream.avail_out = uInt(outputCount) - uInt(stream.total_out)

                    result = deflate(&stream, Z_FINISH)

                    stream.next_out = nil
                }

                stream.next_in = nil
            }

        } while stream.avail_out == 0 && result != Z_STREAM_END

        guard deflateEnd(&stream) == Z_OK, result == Z_STREAM_END else {
            throw AlgoliaError
                .runtimeError(
                    Optional(UnsafePointer<CChar>(stream.msg))?
                        .flatMap(String.init(validatingUTF8:)) ?? "Unknown gzip error"
                )
        }

        compressedData.count = Int(stream.total_out)

        return compressedData
    }

    func computeChecksum() -> UInt {
        self.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> UInt in
            crc32(0, ptr.baseAddress, numericCast(ptr.count))
        }
    }
}
