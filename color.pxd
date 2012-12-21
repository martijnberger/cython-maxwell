# -*- coding: utf-8 -*-

ctypedef unsigned int dword
ctypedef unsigned short word
ctypedef double real

from vectors cimport *

cdef extern from "h/color.h":
    ctypedef int byte "byte"
    ctypedef int bool "bool"
    cdef cppclass Crgb
    cdef cppclass Cxyz
    cdef cppclass Chsv
    cdef cppclass Cyiq
    cdef cppclass CspectrumComplete
    cdef cppclass Cspectrum

    cdef cppclass Crgb8T[Cprecision]:
        assign(Cprecision cr, Cprecision cg, Cprecision cb)

    cdef cppclass Crgba8T[Cprecision]:
        assign(Cprecision cr, Cprecision cg, Cprecision cb, Cprecision ca)

    cdef cppclass Crgb8(Crgb8T[byte]):
        byte r
        byte g
        byte b
        byte a
        toRGB(Crgb &rgb)
        setZero()
        dword getSummatory()
        bool isZero()

    cdef cppclass Crgb16(Crgb8T[word]):
        toRGB(Crgb &rgb)
        toRGB8(Crgb &rgb)
        dword getSummatory()

    cdef cppclass Crgba8(Crgba8T[byte]):
        pass

    cdef cppclass Crdba16(Crgba8T[word]):
        setZero()

    cdef cppclass Crgb(Cvector3DT[float]):
        float r
        float g
        float b
        dword get()
        gammaCorrectionRec709(real gamma)
        invGammaCorrectionRec709( real gamma )
        toRGB8( Crgb8 &rgb8 )
        toRGB16( Crgb16 &rgb16 )
        toXYZ( Cxyz &xyz )
        toHSV( Chsv *pHSV ) # devuelve: h entre [0,360], s entre[0,1], v entre[0,1]
        toHsv( float *h, float *s, float *v )
        toYIQ( Cyiq &yiq )
        toReflectanceSpectrum( CspectrumComplete *pSpectrum, real maxReflectance )
        toReflectanceSpectrum( Cspectrum &s, real maxReflectance )
        clip( )
        bool constrain( )
    cdef cppclass Cxyz(Cvector3DT[double]):
        toRGB(Crgb &rgb)