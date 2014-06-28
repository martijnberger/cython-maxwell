# -*- coding: utf-8 -*-

from vectors cimport *

cdef extern from "h/mx_base.h":
    ctypedef Cvector3DT CbaseVector "Cvector3DT<Cprecision>"
    cdef cppclass CbaseT[Cprecicion]:
        CbaseT()
        CvaseT(CbaseVector& _origin, CbaseVector& _xAxis, CbaseVector& _yAxis, CbaseVector& _zAxis )
        initCanonical( )
        Cvector3DT[Cprecicion] origin
        Cvector3DT[Cprecicion] xAxis
        Cvector3DT[Cprecicion] yAxis
        Cvector3DT[Cprecicion] zAxis
    ctypedef CbaseT[double] Cbase
    ctypedef CbaseT[float] CfBase