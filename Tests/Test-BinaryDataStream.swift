/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import XCTest
import DSStore

class TestBinaryDataStream: XCTestCase
{
    func testInit() throws
    {
        let stream1 = BinaryDataStream( bytes: [ 0x00, 0x00 ] )
        let stream2 = BinaryDataStream( data: Data( [ 0x00, 0x00 ] ) )
        
        XCTAssertEqual( stream1.availableBytes(), 2 )
        XCTAssertEqual( stream2.availableBytes(), 2 )
    }
    
    func testHasBytesAvailable() throws
    {
        let stream = BinaryDataStream( bytes: [ 0, 0, 0 ] )
        
        XCTAssertTrue( stream.hasBytesAvailable() )
        
        let _ = try stream.readUInt8()
        
        XCTAssertTrue( stream.hasBytesAvailable() )
        
        let _ = try stream.readUInt8()
        
        XCTAssertTrue( stream.hasBytesAvailable() )
        
        let _ = try stream.readUInt8()
        
        XCTAssertFalse( stream.hasBytesAvailable() )
    }
    
    func testAvailableBytes() throws
    {
        let stream = BinaryDataStream( bytes: [ 0, 0, 0 ] )
        
        XCTAssertEqual( stream.availableBytes(), 3 )
        
        let _ = try stream.readUInt8()
        
        XCTAssertEqual( stream.availableBytes(), 2 )
        
        let _ = try stream.readUInt8()
        
        XCTAssertEqual( stream.availableBytes(), 1 )
        
        let _ = try stream.readUInt8()
        
        XCTAssertEqual( stream.availableBytes(), 0 )
    }
    
    func testTell() throws
    {
        let stream = BinaryDataStream( bytes: [ 0, 0, 0 ] )
        
        XCTAssertEqual( stream.tell(), 0 )
        
        let _ = try stream.readUInt8()
        
        XCTAssertEqual( stream.tell(), 1 )
        
        let _ = try stream.readUInt8()
        
        XCTAssertEqual( stream.tell(), 2 )
        
        let _ = try stream.readUInt8()
        
        XCTAssertEqual( stream.tell(), 3 )
    }
    
    func testSeek() throws
    {
        let stream = BinaryDataStream( bytes: [ 0, 0, 0 ] )
        
        XCTAssertNoThrow( try stream.seek( offset: 0, from: .begin ) )
        XCTAssertEqual( stream.availableBytes(), 3 )
        XCTAssertNoThrow( try stream.seek( offset: 1, from: .begin ) )
        XCTAssertEqual( stream.availableBytes(), 2 )
        XCTAssertNoThrow( try stream.seek( offset: 2, from: .begin ) )
        XCTAssertEqual( stream.availableBytes(), 1 )
        XCTAssertNoThrow( try stream.seek( offset: 3, from: .begin ) )
        XCTAssertEqual( stream.availableBytes(), 0 )
        XCTAssertThrowsError( try stream.seek( offset: 4, from: .begin ) )
        
        XCTAssertNoThrow( try stream.seek( offset: 0, from: .end ) )
        XCTAssertEqual( stream.availableBytes(), 0 )
        XCTAssertNoThrow( try stream.seek( offset: -1, from: .end ) )
        XCTAssertEqual( stream.availableBytes(), 1 )
        XCTAssertNoThrow( try stream.seek( offset: -2, from: .end ) )
        XCTAssertEqual( stream.availableBytes(), 2 )
        XCTAssertNoThrow( try stream.seek( offset: -3, from: .end ) )
        XCTAssertEqual( stream.availableBytes(), 3 )
        XCTAssertThrowsError( try stream.seek( offset: -4, from: .end ) )
        
        XCTAssertNoThrow( try stream.seek( offset: 1, from: .current ) )
        XCTAssertEqual( stream.availableBytes(), 2 )
        XCTAssertNoThrow( try stream.seek( offset: 1, from: .current ) )
        XCTAssertEqual( stream.availableBytes(), 1 )
        XCTAssertNoThrow( try stream.seek( offset: 1, from: .current ) )
        XCTAssertEqual( stream.availableBytes(), 0 )
        XCTAssertThrowsError( try stream.seek( offset: 1, from: .current ) )
    }
    
    func testRead() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81 ] )
        let read1  = try stream.read( size: 2 )
        let read2  = try stream.read( size: 4 )
        
        XCTAssertEqual( read1, [ 0x00, 0x42 ] )
        XCTAssertEqual( read2, [ 0x43, 0x44, 0x80, 0x81 ] )
        
        XCTAssertThrowsError( try stream.read( size: 1 ) )
    }
    
    func testReadInBuffer() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81 ] )
        let buff1  = UnsafeMutableBufferPointer< UInt8 >.allocate( capacity: 2 )
        let buff2  = UnsafeMutableBufferPointer< UInt8 >.allocate( capacity: 4 )
        
        defer
        {
            buff1.deallocate()
            buff2.deallocate()
        }
        
        XCTAssertThrowsError( try stream.read( buffer: buff1, size: 4 ) )
        
        XCTAssertNoThrow( try stream.read( buffer: buff1, size: 2 ) )
        XCTAssertNoThrow( try stream.read( buffer: buff2, size: 4 ) )
        
        XCTAssertEqual( buff1.toArray(), [ 0x00, 0x42 ] )
        XCTAssertEqual( buff2.toArray(), [ 0x43, 0x44, 0x80, 0x81 ] )
        
        XCTAssertThrowsError( try stream.read( buffer: buff2, size: 1 ) )
    }
    
    func testReadAll() throws
    {
        let data: [ UInt8 ] = [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81 ]
        let stream          = BinaryDataStream( bytes: data )
        let read            = try stream.readAll()
        
        XCTAssertEqual( data, read )
        XCTAssertNoThrow( try stream.readAll() )
        XCTAssertEqual( try stream.readAll().count, 0 )
    }
    
    func testReadUInt8() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81 ] )
        
        XCTAssertEqual( try stream.readUInt8(), 0x00 )
        XCTAssertEqual( try stream.readUInt8(), 0x42 )
        XCTAssertEqual( try stream.readUInt8(), 0x43 )
        XCTAssertEqual( try stream.readUInt8(), 0x44 )
        XCTAssertEqual( try stream.readUInt8(), 0x80 )
        XCTAssertEqual( try stream.readUInt8(), 0x81 )
        XCTAssertThrowsError( try stream.readUInt8() )
    }
    
    func testReadInt8() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81 ] )
        
        XCTAssertEqual( try stream.readInt8(), Int8( bitPattern: 0x00 ) )
        XCTAssertEqual( try stream.readInt8(), Int8( bitPattern: 0x42 ) )
        XCTAssertEqual( try stream.readInt8(), Int8( bitPattern: 0x43 ) )
        XCTAssertEqual( try stream.readInt8(), Int8( bitPattern: 0x44 ) )
        XCTAssertEqual( try stream.readInt8(), Int8( bitPattern: 0x80 ) )
        XCTAssertEqual( try stream.readInt8(), Int8( bitPattern: 0x81 ) )
        XCTAssertThrowsError( try stream.readInt8() )
    }
    
    func testReadUInt16LittleEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readUInt16( endianness: .little ), 0x4200 )
        XCTAssertEqual( try stream.readUInt16( endianness: .little ), 0x4443 )
        XCTAssertEqual( try stream.readUInt16( endianness: .little ), 0x8180 )
        XCTAssertEqual( try stream.readUInt16( endianness: .little ), 0x8382 )
        XCTAssertThrowsError( try stream.readUInt16( endianness: .little ) )
    }
    
    func testReadUInt16BigEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readUInt16( endianness: .big ), 0x0042 )
        XCTAssertEqual( try stream.readUInt16( endianness: .big ), 0x4344 )
        XCTAssertEqual( try stream.readUInt16( endianness: .big ), 0x8081 )
        XCTAssertEqual( try stream.readUInt16( endianness: .big ), 0x8283 )
        XCTAssertThrowsError( try stream.readUInt16( endianness: .big ) )
    }
    
    func testReadInt16LittleEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readInt16( endianness: .little ), Int16( bitPattern: 0x4200 ) )
        XCTAssertEqual( try stream.readInt16( endianness: .little ), Int16( bitPattern: 0x4443 ) )
        XCTAssertEqual( try stream.readInt16( endianness: .little ), Int16( bitPattern: 0x8180 ) )
        XCTAssertEqual( try stream.readInt16( endianness: .little ), Int16( bitPattern: 0x8382 ) )
        XCTAssertThrowsError( try stream.readInt16( endianness: .little ) )
    }
    
    func testReadInt16BigEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readInt16( endianness: .big ), Int16( bitPattern: 0x0042 ) )
        XCTAssertEqual( try stream.readInt16( endianness: .big ), Int16( bitPattern: 0x4344 ) )
        XCTAssertEqual( try stream.readInt16( endianness: .big ), Int16( bitPattern: 0x8081 ) )
        XCTAssertEqual( try stream.readInt16( endianness: .big ), Int16( bitPattern: 0x8283 ) )
        XCTAssertThrowsError( try stream.readInt16( endianness: .big ) )
    }
    
    func testReadUInt32LittleEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readUInt32( endianness: .little ), 0x44434200 )
        XCTAssertEqual( try stream.readUInt32( endianness: .little ), 0x83828180 )
        XCTAssertThrowsError( try stream.readUInt32( endianness: .little ) )
    }
    
    func testReadUInt32BigEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readUInt32( endianness: .big ), 0x00424344 )
        XCTAssertEqual( try stream.readUInt32( endianness: .big ), 0x80818283 )
        XCTAssertThrowsError( try stream.readUInt32( endianness: .big ) )
    }
    
    func testReadInt32LittleEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readInt32( endianness: .little ), Int32( bitPattern: 0x44434200 ) )
        XCTAssertEqual( try stream.readInt32( endianness: .little ), Int32( bitPattern: 0x83828180 ) )
        XCTAssertThrowsError( try stream.readInt32( endianness: .little ) )
    }
    
    func testReadInt32BigEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readInt32( endianness: .big ), Int32( bitPattern: 0x00424344 ) )
        XCTAssertEqual( try stream.readInt32( endianness: .big ), Int32( bitPattern: 0x80818283 ) )
        XCTAssertThrowsError( try stream.readInt32( endianness: .big ) )
    }
    
    func testReadUInt64LittleEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readUInt64( endianness: .little ), 0x4443420044434200 )
        XCTAssertEqual( try stream.readUInt64( endianness: .little ), 0x8382818083828180 )
        XCTAssertThrowsError( try stream.readUInt64( endianness: .little ) )}
    
    func testReadUInt64BigEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readUInt64( endianness: .big ), 0x42434400424344 )
        XCTAssertEqual( try stream.readUInt64( endianness: .big ), 0x8081828380818283 )
        XCTAssertThrowsError( try stream.readUInt64( endianness: .big ) )
    }
    
    func testReadInt64LittleEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readInt64( endianness: .little ), Int64( bitPattern: 0x4443420044434200 ) )
        XCTAssertEqual( try stream.readInt64( endianness: .little ), Int64( bitPattern: 0x8382818083828180 ) )
        XCTAssertThrowsError( try stream.readInt64( endianness: .little ) )
    }
    
    func testReadInt64BigEndian() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x00, 0x42, 0x43, 0x44, 0x00, 0x42, 0x43, 0x44, 0x80, 0x81, 0x82, 0x83, 0x80, 0x81, 0x82, 0x83 ] )
        
        XCTAssertEqual( try stream.readInt64( endianness: .big ), Int64( bitPattern: 0x42434400424344 ) )
        XCTAssertEqual( try stream.readInt64( endianness: .big ), Int64( bitPattern: 0x8081828380818283 ) )
        XCTAssertThrowsError( try stream.readInt64( endianness: .big ) )
    }
    
    func testReadString() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x41, 0x42, 0x43, 0x44, 0x45, 0x46 ] )
        let str1   = try stream.readString( length: 2, encoding: .utf8 )
        let str2   = try stream.readString( length: 4, encoding: .utf8 )
        
        XCTAssertNotNil( str1 )
        XCTAssertNotNil( str2 )
        
        XCTAssertEqual( str1, "AB" )
        XCTAssertEqual( str2, "CDEF" )
        
        XCTAssertThrowsError( try stream.readString( length: 1, encoding: .utf8 ) )
    }
    
    func readNULLTerminatedString() throws
    {
        let stream = BinaryDataStream( bytes: [ 0x41, 0x42, 0x00, 0x43, 0x44, 0x45, 0x46, 0x00, 0x00 ] )
        let str1   = try stream.readNULLTerminatedString( encoding: .utf8 )
        let str2   = try stream.readNULLTerminatedString( encoding: .utf8 )
        let str3   = try stream.readNULLTerminatedString( encoding: .utf8 )
        
        XCTAssertNotNil( str1 )
        XCTAssertNotNil( str2 )
        XCTAssertNotNil( str3 )
        
        XCTAssertEqual( str1, "AB" )
        XCTAssertEqual( str2, "CDEF" )
        XCTAssertEqual( str3, "" )
        
        XCTAssertThrowsError( try stream.readNULLTerminatedString( encoding: .utf8 ) )
    }
}
