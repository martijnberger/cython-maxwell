# -*- coding: utf-8 -*-

cdef extern from "h/mx_vectors.h":
    ctypedef int byte "byte"
    cdef cppclass Cvector2DT[Cprecision]:
        Cvector2DT()
    cdef cppclass Cvector3DT[Cprecision]:
        Cprecision x, y, z, r, g, b, u, v, w
        Cvector3DT()
        Cvector3DT(Cprecision _x, Cprecision _y, Cprecision _z)
        byte isNull()
        setZero()



    ctypedef Cvector2DT[float] CfVector2D
    ctypedef Cvector2DT[double] Cvector2D
    ctypedef Cvector3DT[float] CfVector
    ctypedef Cvector3DT[double] Cvector
    ctypedef Cvector2D Cpoint2D
    ctypedef CfVector2D CfPoint2D
    ctypedef Cvector Cpoint
    ctypedef CfVector CfPoint