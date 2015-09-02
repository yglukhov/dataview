
when defined(js):
    type
        DataView* = ref DataViewObj
        DataViewObj {.importc.} = object
            getInt8*: proc (offset: int): int8
            getInt16*: proc (offset: int): int16
            getInt32*: proc (offset: int): int32
            getUint8*: proc (offset: int): uint8
            getUint16*: proc (offset: int): uint16
            getUint32*: proc (offset: int): uint32
            getFloat32*: proc (offset: int): float32
            getFloat64*: proc (offset: int): float64

            setInt8*: proc (offset: int, value: int8)
            setInt16*: proc (offset: int, value: int16)
            setInt32*: proc (offset: int, value: int32)
            setUint8*: proc (offset: int, value: uint8)
            setUint16*: proc (offset: int, value: uint16)
            setUint32*: proc (offset: int, value: uint32)
            setFloat32*: proc (offset: int, value: float32)
            setFloat64*: proc (offset: int, value: float64)

            byteLength*: int

    proc newDataView*(s: seq[int8]): DataView not nil =
        {.emit: "`result` = new DataView(((`s` instanceof Int8Array) ? `s` : new Int8Array(`s`)).buffer);".}
    proc newDataView*(s: seq[int16]): DataView not nil =
        {.emit: "`result` = new DataView(((`s` instanceof Int16Array) ? `s` : new Int16Array(`s`)).buffer);".}
    proc newDataView*(s: seq[int32]): DataView not nil =
        {.emit: "`result` = new DataView(((`s` instanceof Int32Array) ? `s` : new Int32Array(`s`)).buffer);".}
    proc newDataView*(s: seq[uint8]): DataView not nil =
        {.emit: "`result` = new DataView(((`s` instanceof Uint8Array) ? `s` : new Uint8Array(`s`)).buffer);".}
    proc newDataView*(s: seq[uint16]): DataView not nil =
        {.emit: "`result` = new DataView(((`s` instanceof Int16Array) ? `s` : new Int16Array(`s`)).buffer);".}
    proc newDataView*(s: seq[uint32]): DataView not nil =
        {.emit: "`result` = new DataView(((`s` instanceof Uint32Array) ? `s` : new Uint32Array(`s`)).buffer);".}

    proc newDataView*(s: seq[float32]): DataView not nil =
        {.emit: "`result` = new DataView(((`s` instanceof Float32Array) ? `s` : new Float32Array(`s`)).buffer);".}
    proc newDataView*(s: seq[float64]): DataView not nil =
        {.emit: "`result` = new DataView(((`s` instanceof Float64Array) ? `s` : new Float64Array(`s`)).buffer);".}

else:
    type DataView* = ref object of RootObj

    method getInt8*(dv: DataView, offset: int): int8 = discard
    method getInt16*(dv: DataView, offset: int): int16 = discard
    method getInt32*(dv: DataView, offset: int): int32 = discard
    method getUint8*(dv: DataView, offset: int): uint8 = discard
    method getUint16*(dv: DataView, offset: int): uint16 = discard
    method getUint32*(dv: DataView, offset: int): uint32 = discard
    method getFloat32*(dv: DataView, offset: int): float32 = discard
    method getFloat64*(dv: DataView, offset: int): float64 = discard

    method setInt8*(dv: DataView, offset: int, value: int8) = discard
    method setInt16*(dv: DataView, offset: int, value: int16) = discard
    method setInt32*(dv: DataView, offset: int, value: int32) = discard
    method setUint8*(dv: DataView, offset: int, value: uint8) = discard
    method setUint16*(dv: DataView, offset: int, value: uint16) = discard
    method setUint32*(dv: DataView, offset: int, value: uint32) = discard
    method setFloat32*(dv: DataView, offset: int, value: float32) = discard
    method setFloat64*(dv: DataView, offset: int, value: float64) = discard

    method byteLength*(dv: DataView): int = discard

    type RawPtrDataView* = ref object of DataView
        start: pointer
        length: uint64

    proc getValue[T](dv: RawPtrDataView, offset: int, value: var T) {.inline.} =
        if uint64(offset + sizeof(value)) >= dv.length:
            raise newException(AccessViolationError, "DataView read out of bounds")
        value = (cast[ptr T](cast[int](dv.start) + offset))[]

    proc setValue[T](dv: RawPtrDataView, offset: int, value: T) {.inline.} =
        if uint64(offset + sizeof(value)) >= dv.length:
            raise newException(AccessViolationError, "DataView write out of bounds")
        (cast[ptr T](cast[int](dv.start) + offset))[] = value

    method getInt8*(dv: RawPtrDataView, offset: int): int8 = dv.getValue(offset, result)
    method getInt16*(dv: RawPtrDataView, offset: int): int16 = dv.getValue(offset, result)
    method getInt32*(dv: RawPtrDataView, offset: int): int32 = dv.getValue(offset, result)
    method getUint8*(dv: RawPtrDataView, offset: int): uint8 = dv.getValue(offset, result)
    method getUint16*(dv: RawPtrDataView, offset: int): uint16 = dv.getValue(offset, result)
    method getUint32*(dv: RawPtrDataView, offset: int): uint32 = dv.getValue(offset, result)
    method getFloat32*(dv: RawPtrDataView, offset: int): float32 = dv.getValue(offset, result)
    method getFloat64*(dv: RawPtrDataView, offset: int): float64 = dv.getValue(offset, result)

    method setInt8*(dv: RawPtrDataView, offset: int, value: int8) = dv.setValue(offset, value)
    method setInt16*(dv: RawPtrDataView, offset: int, value: int16) = dv.setValue(offset, value)
    method setInt32*(dv: RawPtrDataView, offset: int, value: int32) = dv.setValue(offset, value)
    method setUint8*(dv: RawPtrDataView, offset: int, value: uint8) = dv.setValue(offset, value)
    method setUint16*(dv: RawPtrDataView, offset: int, value: uint16) = dv.setValue(offset, value)
    method setUint32*(dv: RawPtrDataView, offset: int, value: uint32) = dv.setValue(offset, value)
    method setFloat32*(dv: RawPtrDataView, offset: int, value: float32) = dv.setValue(offset, value)
    method setFloat64*(dv: RawPtrDataView, offset: int, value: float64) = dv.setValue(offset, value)

    method byteLength*(dv: RawPtrDataView): int = dv.length.int

    type SeqDataView[T] = ref object of RawPtrDataView
        buffer: seq[T]

    type AnyTypedArrayElementType = int8 | int16 | int32 | uint8 | uint16 | uint32 | float32 | float64

    proc newDataView*[AnyTypedArrayElementType](s: seq[AnyTypedArrayElementType]): DataView =
        let r = new(SeqDataView[AnyTypedArrayElementType])
        r.buffer = s
        r.start = addr r.buffer[0]
        r.length = uint64(r.buffer.len * sizeof(AnyTypedArrayElementType))
        result = r

when isMainModule:
    let s = @[1.uint32, 2, 3, 4]
    let dv = newDataView(s)

    doAssert(dv.byteLength == 16)

    doAssert(dv.getInt8(0) == 1)
    doAssert(dv.getInt8(1) == 0)
    doAssert(dv.getInt8(2) == 0)
    doAssert(dv.getInt8(3) == 0)
    doAssert(dv.getInt8(4) == 2)
    doAssert(dv.getInt8(5) == 0)
    doAssert(dv.getInt8(6) == 0)
    doAssert(dv.getInt8(7) == 0)
