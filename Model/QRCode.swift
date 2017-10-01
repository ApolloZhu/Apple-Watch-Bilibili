//
//  QRCode.swift
//  bilibili
//
//  Created by Apollo Zhu on 9/30/17.
//  Copyright © 2017 Apollo Zhu. All rights reserved.
//

/**
 * @fileoverview
 * - Using the 'QRCode for Javascript library'
 * - Fixed dataset of 'QRCode for Javascript library' for support full-spec.
 * - self.library has no dependencies.
 *
 * @author davidshimjs
 * @see <a href="http://www.d-project.com/" target="_blank">http://www.d-project.com/</a>
 * @see <a href="http://jeromeetienne.github.com/jquery-qrcode/" target="_blank">http://jeromeetienne.github.com/jquery-qrcode/</a>
 */

import Foundation
import Accelerate

//---------------------------------------------------------------------
// QRCode for JavaScript
//
// Copyright (c) 2009 Kazuhiko Arase
//
// URL: http://www.d-project.com/
//
// Licensed under the MIT license:
//   http://www.opensource.org/licenses/mit-license.php
//
// The word "QR Code" is registered trademark of
// DENSO WAVE INCORPORATED
//   http://www.denso-wave.com/qrcode/faqpatent-e.html
//
//---------------------------------------------------------------------
struct QRCode {
    /**
     * @name QRCode.CorrectLevel
     */
    let correctLevel: QRErrorCorrectLevel = .H
}

enum QRErrorCorrectLevel: Int {
    case L = 1
    case M = 0
    case Q = 3
    case H = 2
}

enum QRMode: Int { // OptionSet
    case MODE_NUMBER = 0b0001 // 1 << 0
    case MODE_ALPHA_NUM = 0b0010 // 1 << 1
    case MODE_8BIT_BYTE = 0b0100 //1 << 2
    case MODE_KANJI = 0b1000 // 1 << 3
}

enum QRMaskPattern: Int {
    case PATTERN000 = 0
    case PATTERN001 = 1
    case PATTERN010 = 2
    case PATTERN011 = 3
    case PATTERN100 = 4
    case PATTERN101 = 5
    case PATTERN110 = 6
    case PATTERN111 = 7
}

struct QR8bitByte {
    let mode: QRMode = .MODE_8BIT_BYTE
    let data: String
    let parsedData: Data!
        init(_ data: String) {
            self.data = data
            parsedData = data.data(using: .utf8)
        }

    func getLength(_ buffer: Any) - > Int {
        return parsedData.count
    }

    func write(_ buffer: Any) {
        let l = parsedData.count
        for i in 0.. < l {
            buffer.put(parsedData[i], 8)
        }
    }
}

struct Error: Swift.Error {
    var localizedDescription: String {
        return _localizedDescription
    }
    let _localizedDescription: String
    init(_ description: String) {
        _localizedDescription = description
    }
}

struct QRCodeModel {
    let typeNumber: Int
    let errorCorrectLevel: QRErrorCorrectLevel
    var modules: [
        [Bool ? ]
    ] ! = nil
    var moduleCount = 0
    var dataCache: Any! = nil
    var dataList = [QR8bitByte]()
    init(_ typeNumber: Int, _ errorCorrectLevel: QRErrorCorrectLevel) {
        self.typeNumber = typeNumber
        self.errorCorrectLevel = errorCorrectLevel
    }
    mutating func addData(_ data: String) {
        let newData = QR8bitByte(data)
        dataList.append(newData)
        dataCache = nil
    }
    func isDark(_ row: Int, _ col: Int) throws - > Any {
        if (row < 0 || self.moduleCount <= row || col < 0 || self.moduleCount <= col) {
            throw Error("\(row),\(col)")
        }
        return modules[row][col]
    }

    func getModuleCount() - > Int {
        return moduleCount
    }

    func make() {
        makeImpl(false, getBestMaskPattern())
    }

    mutating func makeImpl(_ test: Bool, _ maskPattern: Int) {
        moduleCount = typeNumber * 4 + 17
        modules = [
            [Bool ? ]
        ](repeatElement(
            [Bool ? ](repeatElement(nil, count: moduleCount)), count: moduleCount))

        setupPositionProbePattern(0, 0);
        setupPositionProbePattern(moduleCount - 7, 0);
        setupPositionProbePattern(0, moduleCount - 7);
        setupPositionAdjustPattern()
        setupTimingPattern()
        setupTypeInfo(test, maskPattern)
        if (typeNumber >= 7) {
            setupTypeNumber(test)
        }
        if (dataCache == nil) {
            dataCache = QRCodeModel.createData(typeNumber, errorCorrectLevel, dataList)
        }
        mapData(dataCache, maskPattern)
    }

    mutating func setupPositionProbePattern(_ row: Int, _ col: Int) {
        for r in -1...7 {
            if (row + r <= -1 || moduleCount <= row + r) {
                continue
            }
            for c in -1...7 {
                if (col + c <= -1 || moduleCount <= col + c) {
                    continue
                }
                if ((0 <= r && r <= 6 && (c == 0 || c == 6)) || (0 <= c && c <= 6 && (r == 0 || r == 6)) || (2 <= r && r <= 4 && 2 <= c && c <= 4)) {
                    modules[row + r][col + c] = true
                } else {
                    modules[row + r][col + c] = false
                }
            }
        }
    }

    func getBestMaskPattern() - > Any {
        var minLostPoint = 0
        var pattern = 0
        for i in 0.. < 8 {
            makeImpl(true, i)
            let lostPoint = QRUtil.getLostPoint(self)
            if (i == 0 || minLostPoint > lostPoint) {
                minLostPoint = lostPoint
                pattern = i
            }
        }
        return pattern;
    }

    func createMovieClip(_ target_mc: Any, _ instance_name: Any, _ depth: Any) - > Any {
        var qr_mc: Any = target_mc.createEmptyMovieClip(instance_name, depth)
        var cs = 1
        make()
        for row in 0.. < modules.count {
            var y = row * cs
            for col in 0.. < modules[row].count {
                let x = col * cs
                let dark = modules[row][col]
                if (dark) {
                    qr_mc.beginFill(0, 100)
                    qr_mc.moveTo(x, y)
                    qr_mc.lineTo(x + cs, y)
                    qr_mc.lineTo(x + cs, y + cs)
                    qr_mc.lineTo(x, y + cs)
                    qr_mc.endFill()
                }
            }
        }
        return qr_mc
    }

    mutating func setupTimingPattern() {
        for r in 8.. < moduleCount - 8 {
            if (modules[r][6] != nil) {
                continue
            }
            modules[r][6] = (r % 2 == 0);
        }
        for c in 8.. < moduleCount - 8 {
            if (modules[6][c] != nil) {
                continue
            }
            modules[6][c] = (c % 2 == 0)
        }
    }

    mutating func setupPositionAdjustPattern() {
        let pos = QRUtil.getPatternPosition(typeNumber)
        for i in 0.. < pos.length {
            for j in 0.. < pos.length {
                let row = pos[i]
                let col = pos[j]
                if (modules[row][col] != nil) {
                    continue;
                }
                for r in -2...2 {
                    for c in -2...2 {
                        if (r == -2 || r == 2 || c == -2 || c == 2 || (r == 0 && c == 0)) {
                            modules[row + r][col + c] = true
                        } else {
                            modules[row + r][col + c] = false
                        }
                    }
                }
            }
        }
    }

    mutating func setupTypeNumber(_ test: Bool) {
        var bits = QRUtil.getBCHTypeNumber(self.typeNumber)
        // FIXME: Optimize Loop
        for i in 0.. < 18 {
            let mod = (!test && ((bits >> i) & 1) == 1)
            modules[floor(i / 3)][i % 3 + moduleCount - 8 - 3] = mod
        }
        for i in 0.. < 18 {
            let mod = (!test && ((bits >> i) & 1) == 1)
            modules[i % 3 + moduleCount - 8 - 3][floor(i / 3)] = mod
        }
    }

    mutating func setupTypeInfo(_ test: Bool, _ maskPattern: Any) {
        let data = (errorCorrectLevel << 3) | maskPattern
        let bits = QRUtil.getBCHTypeInfo(data)
        // FIXME: Optimize Loop
        for i in 0.. < 15 {
            let mod = (!test && ((bits >> i) & 1) == 1)
            if (i < 6) {
                modules[i][8] = mod
            } else if (i < 8) {
                modules[i + 1][8] = mod
            } else {
                modules[moduleCount - 15 + i][8] = mod
            }
        }
        for i in 0.. < 15 {
            var mod = (!test && ((bits >> i) & 1) == 1)
            if (i < 8) {
                modules[8][self.moduleCount - i - 1] = mod
            } else if (i < 9) {
                modules[8][15 - i - 1 + 1] = mod
            } else {
                modules[8][15 - i - 1] = mod
            }
        }
        modules[moduleCount - 8][8] = !test
    }

    mutating func mapData(_ data: [Any], _ maskPattern: Any) {
        var inc = -1
        var row = moduleCount - 1
        var bitIndex = 7
        var byteIndex = 0

        for
        var col in stride(from: moduleCount - 1, to: 0, by: -2) {
            if (col == 6) {
                col -= 1
            }
            while (true) {
                for c in 0.. < 2 {
                    if modules[row][col - c] == nil {
                        var dark = false
                        if byteIndex < data.count {
                            dark = (((data[byteIndex] >>> bitIndex) & 1) == 1)
                        }
                        let mask = QRUtil.getMask(maskPattern, row, col - c)
                        if mask {
                            dark = !dark;
                        }
                        modules[row][col - c] = dark
                        bitIndex -= 1
                        if bitIndex == -1 {
                            byteIndex += 1
                            bitIndex = 7
                        }
                    }
                }
                row += inc
                if row < 0 || moduleCount <= row {
                    row -= inc
                    inc = -inc
                    break
                }
            }
        }
    }

    static
    let PAD0 = 0xEC
    static
    let PAD1 = 0x11


    static func createData(_ typeNumber: Int, _ errorCorrectLevel: QRErrorCorrectLevel, dataList: [QR8bitByte]) throws {
        var rsBlocks = QRRSBlock.getRSBlocks(typeNumber, errorCorrectLevel);
        var buffer = QRBitBuffer()
        for i in 0.. < dataList.count {
            let data = dataList[i]
            buffer.put(data.mode, 4)
            buffer.put(data.getLength(), QRUtil.getLengthInBits(data.mode, typeNumber))
            data.write(buffer)
        }
        var totalDataCount = 0
        for i in 0.. < rsBlocks.count {
            totalDataCount += rsBlocks[i].dataCount
        }
        if (buffer.getLengthInBits() > totalDataCount * 8) {
            throw Error("code length overflow. (\(buffer.getLengthInBits())>\(totalDataCount * 8))")
        }
        if buffer.getLengthInBits() + 4 <= totalDataCount * 8 {
            buffer.put(0, 4)
        }
        while buffer.getLengthInBits() % 8 != 0 {
            buffer.putBit(false);
        }
        while (true) {
            if buffer.getLengthInBits() >= totalDataCount * 8 {
                break
            }
            buffer.put(QRCodeModel.PAD0, 8)
            if buffer.getLengthInBits() >= totalDataCount * 8 {
                break
            }
            buffer.put(QRCodeModel.PAD1, 8)
        }
        return QRCodeModel.createBytes(buffer, rsBlocks)
    }

    static func createBytes(_ buffer: Any, rsBlocks: [Any]) {
        var offset = 0
        var maxDcCount = 0
        var maxEcCount = 0
        var dcdata = [](rsBlocks.count)
        var ecdata = [](rsBlocks.count)
        for r in 0.. < rsBlocks.count {
            var dcCount = rsBlocks[r].dataCount
            var ecCount = rsBlocks[r].totalCount - dcCount
            maxDcCount = max(maxDcCount, dcCount)
            maxEcCount = max(maxEcCount, ecCount)
            dcdata[r] = [](dcCount)
            for i in 0.. < dcdata[r].count {
                dcdata[r][i] = 0xff & buffer.buffer[i + offset]
            }
            offset += dcCount
            var rsPoly = QRUtil.getErrorCorrectPolynomial(ecCount)
            var rawPoly = QRPolynomial(dcdata[r], rsPoly.getLength() - 1)
            var modPoly = rawPoly.mod(rsPoly)
            ecdata[r] = [](rsPoly.getLength() - 1)
            for i in 0.. < ecdata[r].length {
                let modIndex = i + modPoly.getLength() - ecdata[r].length
                ecdata[r][i] = (modIndex >= 0) ? modPoly.get(modIndex) : 0
            }
        }
        var totalCodeCount = 0
        for i in 0.. < rsBlocks.count {
            totalCodeCount += rsBlocks[i].totalCount
        }
        var data = [](totalCodeCount)
        var index = 0
        for i in 0.. < maxDcCount {
            for r in 0.. < rsBlocks.count {
                if i < dcdata[r].count {
                    data[index] = dcdata[r][i]
                    index += 1
                }
            }
        }
        for i in 0.. < maxEcCount {
            for r in 0.. < rsBlocks.count {
                if i < ecdata[r].count {
                    data[index] = ecdata[r][i]
                    index += 1
                }
            }
        }
        return data
    }
}

// Might be part of the QRCodeModel
struct QRUtil {
    static
    let PATTERN_POSITION_TABLE = [
        [],
        [6, 18],
        [6, 22],
        [6, 26],
        [6, 30],
        [6, 34],
        [6, 22, 38],
        [6, 24, 42],
        [6, 26, 46],
        [6, 28, 50],
        [6, 30, 54],
        [6, 32, 58],
        [6, 34, 62],
        [6, 26, 46, 66],
        [6, 26, 48, 70],
        [6, 26, 50, 74],
        [6, 30, 54, 78],
        [6, 30, 56, 82],
        [6, 30, 58, 86],
        [6, 34, 62, 90],
        [6, 28, 50, 72, 94],
        [6, 26, 50, 74, 98],
        [6, 30, 54, 78, 102],
        [6, 28, 54, 80, 106],
        [6, 32, 58, 84, 110],
        [6, 30, 58, 86, 114],
        [6, 34, 62, 90, 118],
        [6, 26, 50, 74, 98, 122],
        [6, 30, 54, 78, 102, 126],
        [6, 26, 52, 78, 104, 130],
        [6, 30, 56, 82, 108, 134],
        [6, 34, 60, 86, 112, 138],
        [6, 30, 58, 86, 114, 142],
        [6, 34, 62, 90, 118, 146],
        [6, 30, 54, 78, 102, 126, 150],
        [6, 24, 50, 76, 102, 128, 154],
        [6, 28, 54, 80, 106, 132, 158],
        [6, 32, 58, 84, 110, 136, 162],
        [6, 26, 54, 82, 110, 138, 166],
        [6, 30, 58, 86, 114, 142, 170]
    ]

    static
    let G15 = (1 << 10) | (1 << 8) | (1 << 5) | (1 << 4) | (1 << 2) | (1 << 1) | (1 << 0)
    static
    let G18 = (1 << 12) | (1 << 11) | (1 << 10) | (1 << 9) | (1 << 8) | (1 << 5) | (1 << 2) | (1 << 0)
    static
    let G15_MASK = (1 << 14) | (1 << 12) | (1 << 10) | (1 << 4) | (1 << 1)


    static func getBCHTypeInfo(_ data: Any) - > Any {
        var d = data << 10
        while QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G15) >= 0 {
            d ^= (QRUtil.G15 << (QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G15)))
        }
        return ((data << 10) | d) ^ QRUtil.G15_MASK
    }

    static func getBCHTypeNumber(_ data: Int) - > Int {
        var d = data << 12;
        while QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G18) >= 0 {
            d ^= (QRUtil.G18 << (QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G18)))
        }
        return (data << 12) | d
    }

    static func getBCHDigit(_ data: Int) - > Int {
        var digit = 0
        while (data != 0) {
            digit += 1
            data >>>= 1
        }
        return digit
    }

    static func getPatternPosition(_ typeNumber: Int) - > [Int] {
        return QRUtil.PATTERN_POSITION_TABLE[typeNumber - 1]
    }

    func getMask(_ maskPattern: QRMaskPattern, _ i: Int, _ j: Int) - > Bool {
        switch (maskPattern) {
            case QRMaskPattern.PATTERN000:
                return (i + j) % 2 == 0;
            case QRMaskPattern.PATTERN001:
                return i % 2 == 0;
            case QRMaskPattern.PATTERN010:
                return j % 3 == 0;
            case QRMaskPattern.PATTERN011:
                return (i + j) % 3 == 0;
            case QRMaskPattern.PATTERN100:
                return (Math.floor(i / 2) + Math.floor(j / 3)) % 2 == 0;
            case QRMaskPattern.PATTERN101:
                return (i * j) % 2 + (i * j) % 3 == 0;
            case QRMaskPattern.PATTERN110:
                return ((i * j) % 2 + (i * j) % 3) % 2 == 0;
            case QRMaskPattern.PATTERN111:
                return ((i * j) % 3 + (i + j) % 2) % 2 == 0;
            default:
                throw Error("bad maskPattern:\(maskPattern)")
        }
    }

    static func getErrorCorrectPolynomial(_ errorCorrectLength: Int) - > QRPolynomial {
        var a = new QRPolynomial([1], 0);
        for i in 0.. < errorCorrectLength {
            a = a.multiply(QRPolynomial([1, QRMath.gexp(i)], 0))
        }
        return a
    }


    static func getLengthInBits(_ mode: QRMode, _ type: Int) throws {
        if 1 <= type && type < 10 {
            switch mode {
                case QRMode.MODE_NUMBER:
                    return 10
                case QRMode.MODE_ALPHA_NUM:
                    return 9
                case QRMode.MODE_8BIT_BYTE:
                    return 8
                case QRMode.MODE_KANJI:
                    return 8
                default:
                    throw Error("mode:\(mode)")
            }
        } else if type < 27 {
            switch mode {
                case QRMode.MODE_NUMBER:
                    return 12
                case QRMode.MODE_ALPHA_NUM:
                    return 11
                case QRMode.MODE_8BIT_BYTE:
                    return 16
                case QRMode.MODE_KANJI:
                    return 10
                default:
                    throw Error("mode:\(mode)")
            }
        } else if type < 41 {
            switch mode {
                case QRMode.MODE_NUMBER:
                    return 14
                case QRMode.MODE_ALPHA_NUM:
                    return 13
                case QRMode.MODE_8BIT_BYTE:
                    return 16
                case QRMode.MODE_KANJI:
                    return 12
                default:
                    throw Error("mode:\(mode)")
            }
        } else {
            throw Error("type:\(type)")
        }
    }

    static func getLostPoint(_ qrCode: Any) {
        var moduleCount = qrCode.getModuleCount()
        var lostPoint = 0
        for row in 0.. < moduleCount {
            for col in 0.. < moduleCount {
                var sameCount = 0
                let dark = qrCode.isDark(row, col)
                for r in -1...1 {
                    if row + r < 0 || moduleCount <= row + r {
                        continue
                    }
                    for c in -1...1 {
                        if col + c < 0 || moduleCount <= col + c {
                            continue
                        }
                        if r == 0 && c == 0 {
                            continue
                        }
                        if dark == qrCode.isDark(row + r, col + c) {
                            sameCount += 1
                        }
                    }
                }
                if sameCount > 5 {
                    lostPoint += (3 + sameCount - 5)
                }
            }
        }
        for row in 0.. < moduleCount - 1 {
            for col in 0.. < moduleCount - 1 {
                var count = 0
                if qrCode.isDark(row, col) {
                    count += 1
                }
                if qrCode.isDark(row + 1, col) {
                    count += 1
                }
                if qrCode.isDark(row, col + 1) {
                    count += 1
                }
                if qrCode.isDark(row + 1, col + 1) {
                    count += 1
                }
                if count == 0 || count == 4 {
                    lostPoint += 3
                }
            }
        }
        for row in 0.. < moduleCount {
            for col in 0.. < moduleCount - 6 {
                if qrCode.isDark(row, col) && !qrCode.isDark(row, col + 1) && qrCode.isDark(row, col + 2) && qrCode.isDark(row, col + 3) && qrCode.isDark(row, col + 4) && !qrCode.isDark(row, col + 5) && qrCode.isDark(row, col + 6) {
                    lostPoint += 40;
                }
            }
        }
        for col in 0.. < moduleCount {
            for row in 0.. < moduleCount - 6 {
                if qrCode.isDark(row, col) && !qrCode.isDark(row + 1, col) && qrCode.isDark(row + 2, col) && qrCode.isDark(row + 3, col) && qrCode.isDark(row + 4, col) && !qrCode.isDark(row + 5, col) && qrCode.isDark(row + 6, col) {
                    lostPoint += 40
                }
            }
        }
        var darkCount = 0
        for col in 0.. < moduleCount {
            for row in 0.. < moduleCount {
                if qrCode.isDark(row, col) {
                    darkCount += 1
                }
            }
        }
        var ratio = abs(100 * darkCount / moduleCount / moduleCount - 50) / 5
        lostPoint += ratio * 10
        return lostPoint
    }
}


struct QRMath {
    static func glog(_ n: Int) throws - > Int {
        if (n < 1) {
            throw Error("glog(\(n))")
        }
        return QRMath.instance.LOG_TABLE[n]
    }

    static func gexp(_ n: Int) - > Int {
        while n < 0 {
            n += 255
        }
        while (n >= 256) {
            n -= 255
        }
        return QRMath.instance.EXP_TABLE[n]
    }

    private
    let EXP_TABLE = [Int](repeatElement: 0, count: 256)
    private
    let LOG_TABLE: [Int](repeatElement: 0, count: 256)

    private static
    let instance = QRMath()
    private init() {
        for i in 0.. < 8 {
            EXP_TABLE[i] = 1 << i
        }
        for i in 8.. < 256 {
            EXP_TABLE[i] = EXP_TABLE[i - 4] ^ EXP_TABLE[i - 5] ^ EXP_TABLE[i - 6] ^ EXP_TABLE[i - 8]
        }
        for i in 0.. < 255 {
            LOG_TABLE[EXP_TABLE[i]] = i
        }
    }
}

struct QRPolynomial {
    var num: [Int]
    init(_ num: [Int], _ shift: Int) {
        if (num.count == 0) {
            throw Error("\(num.count)/\(shift)")
        }
        var offset = 0
        while offset < num.length && num[offset] == 0 {
            offset += 1
        }
        self.num = [](repeatElement: 0, count: num.length - offset + shift)
        for i in 0.. < num.length - offset {
            self.num[i] = num[i + offset]
        }
    }
    func get(_ index: Int) - > Int {
        return num[index]
    }

    func getLength() - > Int {
        return num.count
    }

    func multiply(_ e: QRPolynomial) - > QRPolynomial {
        var num = [Int](repeatElement: 0, count: getLength() + e.getLength() - 1)
        for i in 0.. < getLength() {
            for j in 0.. < e.getLength() {
                num[i + j] ^= QRMath.gexp(QRMath.glog(get(i)) + QRMath.glog(e.get(j)))
            }
        }
        return QRPolynomial(num, 0)
    }

    func mod(_ e: QRPolynomial) - > QRPolynomial {
        if (getLength() - e.getLength() < 0) {
            return self
        }
        var ratio = QRMath.glog(get(0)) - QRMath.glog(e.get(0));
        var num = [Int](repeatElement: 0, count: getLength())
        for i in 0.. < getLength() {
            num[i] = get(i)
        }
        for i in 0.. < e.getLength() {
            num[i] ^= QRMath.gexp(QRMath.glog(e.get(i)) + ratio)
        }
        return QRPolynomial(num, 0).mod(e)
    }
}

struct QRRSBlock {
    let totalCount: Any
    let dataCount: Any
    init(_ totalCount: Any, _ dataCount: Any) {
        self.totalCount = totalCount
        self.dataCount = dataCount
    }

    static
    let RS_BLOCK_TABLE = [
        [1, 26, 19],
        [1, 26, 16],
        [1, 26, 13],
        [1, 26, 9],
        [1, 44, 34],
        [1, 44, 28],
        [1, 44, 22],
        [1, 44, 16],
        [1, 70, 55],
        [1, 70, 44],
        [2, 35, 17],
        [2, 35, 13],
        [1, 100, 80],
        [2, 50, 32],
        [2, 50, 24],
        [4, 25, 9],
        [1, 134, 108],
        [2, 67, 43],
        [2, 33, 15, 2, 34, 16],
        [2, 33, 11, 2, 34, 12],
        [2, 86, 68],
        [4, 43, 27],
        [4, 43, 19],
        [4, 43, 15],
        [2, 98, 78],
        [4, 49, 31],
        [2, 32, 14, 4, 33, 15],
        [4, 39, 13, 1, 40, 14],
        [2, 121, 97],
        [2, 60, 38, 2, 61, 39],
        [4, 40, 18, 2, 41, 19],
        [4, 40, 14, 2, 41, 15],
        [2, 146, 116],
        [3, 58, 36, 2, 59, 37],
        [4, 36, 16, 4, 37, 17],
        [4, 36, 12, 4, 37, 13],
        [2, 86, 68, 2, 87, 69],
        [4, 69, 43, 1, 70, 44],
        [6, 43, 19, 2, 44, 20],
        [6, 43, 15, 2, 44, 16],
        [4, 101, 81],
        [1, 80, 50, 4, 81, 51],
        [4, 50, 22, 4, 51, 23],
        [3, 36, 12, 8, 37, 13],
        [2, 116, 92, 2, 117, 93],
        [6, 58, 36, 2, 59, 37],
        [4, 46, 20, 6, 47, 21],
        [7, 42, 14, 4, 43, 15],
        [4, 133, 107],
        [8, 59, 37, 1, 60, 38],
        [8, 44, 20, 4, 45, 21],
        [12, 33, 11, 4, 34, 12],
        [3, 145, 115, 1, 146, 116],
        [4, 64, 40, 5, 65, 41],
        [11, 36, 16, 5, 37, 17],
        [11, 36, 12, 5, 37, 13],
        [5, 109, 87, 1, 110, 88],
        [5, 65, 41, 5, 66, 42],
        [5, 54, 24, 7, 55, 25],
        [11, 36, 12],
        [5, 122, 98, 1, 123, 99],
        [7, 73, 45, 3, 74, 46],
        [15, 43, 19, 2, 44, 20],
        [3, 45, 15, 13, 46, 16],
        [1, 135, 107, 5, 136, 108],
        [10, 74, 46, 1, 75, 47],
        [1, 50, 22, 15, 51, 23],
        [2, 42, 14, 17, 43, 15],
        [5, 150, 120, 1, 151, 121],
        [9, 69, 43, 4, 70, 44],
        [17, 50, 22, 1, 51, 23],
        [2, 42, 14, 19, 43, 15],
        [3, 141, 113, 4, 142, 114],
        [3, 70, 44, 11, 71, 45],
        [17, 47, 21, 4, 48, 22],
        [9, 39, 13, 16, 40, 14],
        [3, 135, 107, 5, 136, 108],
        [3, 67, 41, 13, 68, 42],
        [15, 54, 24, 5, 55, 25],
        [15, 43, 15, 10, 44, 16],
        [4, 144, 116, 4, 145, 117],
        [17, 68, 42],
        [17, 50, 22, 6, 51, 23],
        [19, 46, 16, 6, 47, 17],
        [2, 139, 111, 7, 140, 112],
        [17, 74, 46],
        [7, 54, 24, 16, 55, 25],
        [34, 37, 13],
        [4, 151, 121, 5, 152, 122],
        [4, 75, 47, 14, 76, 48],
        [11, 54, 24, 14, 55, 25],
        [16, 45, 15, 14, 46, 16],
        [6, 147, 117, 4, 148, 118],
        [6, 73, 45, 14, 74, 46],
        [11, 54, 24, 16, 55, 25],
        [30, 46, 16, 2, 47, 17],
        [8, 132, 106, 4, 133, 107],
        [8, 75, 47, 13, 76, 48],
        [7, 54, 24, 22, 55, 25],
        [22, 45, 15, 13, 46, 16],
        [10, 142, 114, 2, 143, 115],
        [19, 74, 46, 4, 75, 47],
        [28, 50, 22, 6, 51, 23],
        [33, 46, 16, 4, 47, 17],
        [8, 152, 122, 4, 153, 123],
        [22, 73, 45, 3, 74, 46],
        [8, 53, 23, 26, 54, 24],
        [12, 45, 15, 28, 46, 16],
        [3, 147, 117, 10, 148, 118],
        [3, 73, 45, 23, 74, 46],
        [4, 54, 24, 31, 55, 25],
        [11, 45, 15, 31, 46, 16],
        [7, 146, 116, 7, 147, 117],
        [21, 73, 45, 7, 74, 46],
        [1, 53, 23, 37, 54, 24],
        [19, 45, 15, 26, 46, 16],
        [5, 145, 115, 10, 146, 116],
        [19, 75, 47, 10, 76, 48],
        [15, 54, 24, 25, 55, 25],
        [23, 45, 15, 25, 46, 16],
        [13, 145, 115, 3, 146, 116],
        [2, 74, 46, 29, 75, 47],
        [42, 54, 24, 1, 55, 25],
        [23, 45, 15, 28, 46, 16],
        [17, 145, 115],
        [10, 74, 46, 23, 75, 47],
        [10, 54, 24, 35, 55, 25],
        [19, 45, 15, 35, 46, 16],
        [17, 145, 115, 1, 146, 116],
        [14, 74, 46, 21, 75, 47],
        [29, 54, 24, 19, 55, 25],
        [11, 45, 15, 46, 46, 16],
        [13, 145, 115, 6, 146, 116],
        [14, 74, 46, 23, 75, 47],
        [44, 54, 24, 7, 55, 25],
        [59, 46, 16, 1, 47, 17],
        [12, 151, 121, 7, 152, 122],
        [12, 75, 47, 26, 76, 48],
        [39, 54, 24, 14, 55, 25],
        [22, 45, 15, 41, 46, 16],
        [6, 151, 121, 14, 152, 122],
        [6, 75, 47, 34, 76, 48],
        [46, 54, 24, 10, 55, 25],
        [2, 45, 15, 64, 46, 16],
        [17, 152, 122, 4, 153, 123],
        [29, 74, 46, 14, 75, 47],
        [49, 54, 24, 10, 55, 25],
        [24, 45, 15, 46, 46, 16],
        [4, 152, 122, 18, 153, 123],
        [13, 74, 46, 32, 75, 47],
        [48, 54, 24, 14, 55, 25],
        [42, 45, 15, 32, 46, 16],
        [20, 147, 117, 4, 148, 118],
        [40, 75, 47, 7, 76, 48],
        [43, 54, 24, 22, 55, 25],
        [10, 45, 15, 67, 46, 16],
        [19, 148, 118, 6, 149, 119],
        [18, 75, 47, 31, 76, 48],
        [34, 54, 24, 34, 55, 25],
        [20, 45, 15, 61, 46, 16]
    ]


    static func getRSBlocks(_ typeNumber: Int, _ errorCorrectLevel: QRErrorCorrectLevel) - > [QRRSBlock] {
        guard let rsBlock = QRRSBlock.getRsBlockTable(typeNumber, errorCorrectLevel)
        else {
            throw Error("bad rs block @ typeNumber:\(typeNumber)/errorCorrectLevel:\(errorCorrectLevel)")
        }
        var length = rsBlock.count / 3
        var list = [QRRSBlock]()
        for i in 0.. < length {
            var count = rsBlock[i * 3 + 0]
            var totalCount = rsBlock[i * 3 + 1]
            var dataCount = rsBlock[i * 3 + 2]
            for j in 0.. < count {
                list.append(QRRSBlock(totalCount, dataCount))
            }
        }
        return list
    }


    static func getRsBlockTable(_ typeNumber: Int, _ errorCorrectLevel: QRErrorCorrectLevel) -> [Int]? {
        switch (errorCorrectLevel) {
            case QRErrorCorrectLevel.L:
                return QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 0]
            case QRErrorCorrectLevel.M:
                return QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 1]
            case QRErrorCorrectLevel.Q:
                return QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 2]
            case QRErrorCorrectLevel.H:
                return QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 3]
            default:
                return nil
        }
    }
}

struct QRBitBuffer {
    var buffer = [Any]()
    var length = 0

    func get(_ index: Int) {
        var bufIndex = floor(index / 8)
        return ((buffer[bufIndex] >>> (7 - index % 8)) & 1) == 1
    }

    mutating func put(_ num: Int, _ length: Int) {
        for i in 0..<length {
            putBit(((num >>> (length - i - 1)) & 1) == 1)
        }
    }

    func getLengthInBits() -> Int {
        return length
    }

    mutating func putBit(_ bit: Any) {
        var bufIndex = floor(self.length / 8)
        if buffer.length <= bufIndex {
            buffer.append(0)
        }
        if bit {
            buffer[bufIndex] |= (0x80 >>> (length % 8))
        }
        length += 1
    }
}

let QRCodeLimitLength = [
    [17, 14, 11, 7],
    [32, 26, 20, 14],
    [53, 42, 32, 24],
    [78, 62, 46, 34],
    [106, 84, 60, 44],
    [134, 106, 74, 58],
    [154, 122, 86, 64],
    [192, 152, 108, 84],
    [230, 180, 130, 98],
    [271, 213, 151, 119],
    [321, 251, 177, 137],
    [367, 287, 203, 155],
    [425, 331, 241, 177],
    [458, 362, 258, 194],
    [520, 412, 292, 220],
    [586, 450, 322, 250],
    [644, 504, 364, 280],
    [718, 560, 394, 310],
    [792, 624, 442, 338],
    [858, 666, 482, 382],
    [929, 711, 509, 403],
    [1003, 779, 565, 439],
    [1091, 857, 611, 461],
    [1171, 911, 661, 511],
    [1273, 997, 715, 535],
    [1367, 1059, 751, 593],
    [1465, 1125, 805, 625],
    [1528, 1190, 868, 658],
    [1628, 1264, 908, 698],
    [1732, 1370, 982, 742],
    [1840, 1452, 1030, 790],
    [1952, 1538, 1112, 842],
    [2068, 1628, 1168, 898],
    [2188, 1722, 1228, 958],
    [2303, 1809, 1283, 983],
    [2431, 1911, 1351, 1051],
    [2563, 1989, 1423, 1093],
    [2699, 2099, 1499, 1139],
    [2809, 2213, 1579, 1219],
    [2953, 2331, 1663, 1273]
]

// Drawing in DOM by using Table tag
var Drawing = useSVG ? svgDrawer : !_isSupportCanvas() ? (function () {
    var Drawing = function (el, htOption) {
        self._el = el;
        self._htOption = htOption;
    };

    /**
     * Draw the QRCode
     *
     * @param {QRCode} oQRCode
     */
    Drawing.prototype.draw = function (oQRCode) {
        var _htOption = self._htOption;
        var _el = self._el;
        var nCount = oQRCode.getModuleCount();
        var nWidth = Math.floor(_htOption.width / nCount);
        var nHeight = Math.floor(_htOption.height / nCount);
        var aHTML = ['<table style="border:0;border-collapse:collapse;">'];

        for (var row = 0; row < nCount; row++) {
            aHTML.push('<tr>');

            for (var col = 0; col < nCount; col++) {
                aHTML.push('<td style="border:0;border-collapse:collapse;padding:0;margin:0;width:' + nWidth + 'px;height:' + nHeight + 'px;background-color:' + (oQRCode.isDark(row, col) ? _htOption.colorDark : _htOption.colorLight) + ';"></td>');
            }

            aHTML.push('</tr>');
        }

        aHTML.push('</table>');
        _el.innerHTML = aHTML.join('');

        // Fix the margin values as real size.
        var elTable = _el.childNodes[0];
        var nLeftMarginTable = (_htOption.width - elTable.offsetWidth) / 2;
        var nTopMarginTable = (_htOption.height - elTable.offsetHeight) / 2;

        if (nLeftMarginTable > 0 && nTopMarginTable > 0) {
            elTable.style.margin = nTopMarginTable + "px " + nLeftMarginTable + "px";
        }
    };

    /**
     * Clear the QRCode
     */
    Drawing.prototype.clear = function () {
        self._el.innerHTML = '';
    };

    return Drawing;
})() : (function () { // Drawing in Canvas

    /**
     * Check whether the user's browser supports Data URI or not
     *
     * @private
     * @param {Function} fSuccess Occurs if it supports Data URI
     * @param {Function} fFail Occurs if it doesn't support Data URI
     */
    function _safeSetDataURI(fSuccess, fFail) {
        var self = self.
        self._fFail = fFail;
        self._fSuccess = fSuccess;

        // Check it just once
        if (self._bSupportDataURI === null) {
            var el = document.createElement("img");
            var fOnError = function () {
                self._bSupportDataURI = false;

                if (self._fFail) {
                    self._fFail.call(self);
                }
            };
            var fOnSuccess = function () {
                self._bSupportDataURI = true;

                if (self._fSuccess) {
                    self._fSuccess.call(self);
                }
            };

            el.onabort = fOnError;
            el.onerror = fOnError;
            el.onload = fOnSuccess;
            el.src = "data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=="; // the Image contains 1px data.
            return;
        } else if (self._bSupportDataURI === true && self._fSuccess) {
            self._fSuccess.call(self);
        } else if (self._bSupportDataURI === false && self._fFail) {
            self._fFail.call(self);
        }
    };

    /**
     * Draw the QRCode
     *
     * @param {QRCode} oQRCode
     */
    Drawing.prototype.draw = function (oQRCode) {
        var _elImage = self._elImage;
        var _oContext = self._oContext;
        var _htOption = self._htOption;

        var nCount = oQRCode.getModuleCount();
        var nWidth = _htOption.width / nCount;
        var nHeight = _htOption.height / nCount;
        var nRoundedWidth = Math.round(nWidth);
        var nRoundedHeight = Math.round(nHeight);

        _elImage.style.display = "none";
        self.clear();

        for (var row = 0; row < nCount; row++) {
            for (var col = 0; col < nCount; col++) {
                var bIsDark = oQRCode.isDark(row, col);
                var nLeft = col * nWidth;
                var nTop = row * nHeight;
                _oContext.strokeStyle = bIsDark ? _htOption.colorDark : _htOption.colorLight;
                _oContext.lineWidth = 1;
                _oContext.fillStyle = bIsDark ? _htOption.colorDark : _htOption.colorLight;
                _oContext.fillRect(nLeft, nTop, nWidth, nHeight);

                // 안티 앨리어싱 방지 처리
                _oContext.strokeRect(
                    Math.floor(nLeft) + 0.5,
                    Math.floor(nTop) + 0.5,
                    nRoundedWidth,
                    nRoundedHeight
                );

                _oContext.strokeRect(
                    Math.ceil(nLeft) - 0.5,
                    Math.ceil(nTop) - 0.5,
                    nRoundedWidth,
                    nRoundedHeight
                );
            }
        }

        self._bIsPainted = true;
    };

    /**
     * Make the image from Canvas if the browser supports Data URI.
     */
    Drawing.prototype.makeImage = function () {
        if (self._bIsPainted) {
            _safeSetDataURI.call(self._onMakeImage);
        }
    };

    /**
     * Return whether the QRCode is painted or not
     *
     * @return {Boolean}
     */
    Drawing.prototype.isPainted = function () {
        return self._bIsPainted;
    };

    /**
     * Clear the QRCode
     */
    Drawing.prototype.clear = function () {
        self._oContext.clearRect(0, 0, self._elCanvas.width, self._elCanvas.height);
        self._bIsPainted = false;
    };

    /**
     * @private
     * @param {Number} nNumber
     */
    Drawing.prototype.round = function (nNumber) {
        if (!nNumber) {
            return nNumber;
        }

        return Math.floor(nNumber * 1000) / 1000;
    };

    return Drawing;
})();

/**
 * Get the type by string length
 *
 * @private
 * @param {String} sText
 * @param {Number} nCorrectLevel
 * @return {Number} type
 */
function _getTypeNumber(_ sText: String, _ nCorrectLevel: QRErrorCorrectLevel) {
    var nType = 1
    var length = sText.utf8.count
    let len = QRCodeLimitLength.length
    for i in 0...len {
        var nLimit = 0

        switch (nCorrectLevel) {
            case QRErrorCorrectLevel.L:
                nLimit = QRCodeLimitLength[i][0]
            case QRErrorCorrectLevel.M:
                nLimit = QRCodeLimitLength[i][1]
            case QRErrorCorrectLevel.Q:
                nLimit = QRCodeLimitLength[i][2]
            case QRErrorCorrectLevel.H:
                nLimit = QRCodeLimitLength[i][3]
        }

        if (length <= nLimit) {
            break
        } else {
            nType += 1
        }
    }

    if (nType > QRCodeLimitLength.length) {
        throw Error("Too long data");
    }

    return nType;
}

/**
 * @class QRCode
 * @constructor
 * @example
 * new QRCode(document.getElementById("test"), "http://jindo.dev.naver.com/collie");
 *
 * @example
 * var oQRCode = new QRCode("test", {
 *    text : "http://naver.com",
 *    width : 128,
 *    height : 128
 * });
 *
 * oQRCode.clear(); // Clear the QRCode.
 * oQRCode.makeCode("http://map.naver.com"); // Re-create the QRCode.
 *
 * @param {HTMLElement|String} el target element or 'id' attribute of element.
 * @param {Object|String} vOption
 * @param {String} vOption.text QRCode link data
 * @param {Number} [vOption.width=256]
 * @param {Number} [vOption.height=256]
 * @param {String} [vOption.colorDark="#000000"]
 * @param {String} [vOption.colorLight="#ffffff"]
 * @param {QRCode.CorrectLevel} [vOption.correctLevel=QRCode.CorrectLevel.H] [L|M|Q|H]
 */
QRCode = function (el, vOption) {
    self._htOption = {
        width: 256,
        height: 256,
        typeNumber: 4,
        colorDark: "#000000",
        colorLight: "#ffffff",
        correctLevel: QRErrorCorrectLevel.H
    };

    if (typeof vOption === 'string') {
        vOption = {
            text: vOption
        };
    }

    // Overwrites options
    if (vOption) {
        for (var i in vOption) {
            self._htOption[i] = vOption[i];
        }
    }

    if (typeof el == "string") {
        el = document.getElementById(el);
    }

    if (self._htOption.useSVG) {
        Drawing = svgDrawer;
    }

    self._android = _getAndroid();
    self._el = el;
    self._oQRCode = null;
    self._oDrawing = new Drawing(self._el, self._htOption);

    if (self._htOption.text) {
        self.makeCode(self._htOption.text);
    }
};

/**
 * Make the QRCode
 *
 * @param {String} sText link data
 */
QRCode.prototype.makeCode = function (sText) {
    self._oQRCode = new QRCodeModel(_getTypeNumber(sText, self._htOption.correctLevel), self._htOption.correctLevel);
    self._oQRCode.addData(sText);
    self._oQRCode.make();
    self._el.title = sText;
    self._oDrawing.draw(self._oQRCode);
    self.makeImage();
};
