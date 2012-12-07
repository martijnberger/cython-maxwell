from cython.operator cimport dereference as deref, preincrement as inc
from libc.string cimport const_char, const_void
from libc.stdlib cimport malloc, free

cimport cpython
#cimport stdlib

#cdef unicode tounicode(char* s):
#    return s.decode('UTF-8', 'strict')

#cdef unicode tounicode_with_length(
#        char* s, size_t length):
#    return s[:length].decode('UTF-8', 'strict')

#cdef unicode tounicode_with_length_and_free(
#        char* s, size_t length):
#    try:
#        return s[:length].decode('UTF-8', 'strict')
#    finally:
#        stdlib.free(s)

ctypedef unsigned int dword
ctypedef unsigned short word
ctypedef double real

cdef extern from "h/vectors.h":
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


cdef extern from "h/base.h":
    ctypedef Cvector3DT CbaseVector "Cvector3DT<Cprecision>"
    cdef cppclass CbaseT[Cprecicion]:
        CbaseT()
        CvaseT(CbaseVector& _origin, CbaseVector& _xAxis, CbaseVector& _yAxis, CbaseVector& _zAxis )
        initCanonical( )
    ctypedef CbaseT[double] Cbase
    ctypedef CbaseT[float] CfBase


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


cdef extern from "h/flags.h":
    cdef cppclass Cflags[Cprecision]:
        Cflags()

cdef extern from "h/maxwell.h":
    ctypedef real const_real "const real"

    ctypedef unsigned char byte "byte"
    ctypedef int bool "bool"
    ctypedef void* const_CoptionsReadMXS "const Cmaxwell::CoptionsReadMXS"

    cdef cppclass Cmaxwell:
        cppclass Cpointer:
            Cpointer()
            bool isNull()
            void* getPointer()

        cppclass CmaterialPointer(Cpointer):
            CmaterialPointer()

        cppclass CmultiValue:
            #const_char* pID
            #const_char* pType
            #void* pParameter
            CmultiValue(const_char* _pID = NULL, const_char* _pType = NULL, void* _pParameter = NULL)
        cppclass CoptionsReadMXS(Cflags):
            CoptionsReadMXS()

        cppclass CsceneInfo:
            dword nMeshes, nTriangles, nVertexes, nNormals, nMaterials, nBitmaps
            CsceneInfo()
        cppclass Ccamera(Cpointer):
            cppclass Citerator:
                Citerator()
                Ccamera fist(Cmaxwell* pMaxwell)
                Ccamera next()
            Ccamera()
            byte setStep(dword iStep, Cpoint origin, Cpoint focalPoint, Cvector up, real focalLength, real fStop, real stepTime, byte focalLengthNeedCorrection )
            byte getStep( dword iStep, Cpoint& origin, Cpoint& focalPoint, Cvector& up, real& focalLength, real& fStop, real& stepTime )
            byte setOrthoValues( dword iStep, real orthoX, real orthoY, real orthoZoom, real focalLength, real fStop )
            byte getOrthoValues( dword iStep, real& orthoX, real& orthoY, real& orthoZoom, real& focalLength, real& fStop )
            const_char* getValues( dword& nSteps, real& shutter, real& filmWidth, real& filmHeight, real& iso, \
                                   const_char** pDiaphragmType, real& angle, dword& nBlades, \
                                   dword& fps, dword& xRes, dword& yRes, real& pixelAspect, \
                                   byte& projectionType )
            byte setName( const_char* pName )
            const_char* getName()
            byte setResolution( dword xRes, dword yRes )
            byte getResolution( dword& xRes, dword& yRes )
            byte setPixelAspect( real pixelAspect )
            byte getPixelAspect( real& pixelAspect )

            byte setShutter( real shutter )
            byte getShutter( real& shutter )

            byte setIso( real iso )
            byte getIso( real& iso )

            byte setFilmSize( real filmWidth, real filmHeight )
            byte getFilmSize( real& filmWidth, real& filmHeight )

            byte setDiaphragm( const_char* pDiaphragmType, real angle, dword nBlades )
            byte getDiaphragm( const_char** pDiaphragmType, real& angle, dword& nBlades )

            byte setFPS( real fps )
            byte getFPS( real& fps )

            byte setScreenRegion( dword x1, dword y1, dword x2, dword y2, const_char* pRegionType )
            byte getScreenRegion( dword& x1, dword& y1, dword& x2, dword& y2, char* pType )

            byte setCutPlanes( real zNear, real zFar, bool enabled )
            byte getCutPlanes( real& zNear, real& zFar, bool& enabled )

            byte    setShiftLens( real xShift, real yShift )
            byte    getShiftLens( real& xShift, real& yShift )

            # Method:    get/setCustomBokeh.^M
            # Description: Defines a custom bokeh^M
            # Parameters: ^M
            #              ratio: aspect ratio (default: 1)^M
            #              angle: angle in radians^M
            #              enabled: sets the custom bokeh on/off^M
            byte    setCustomBokeh( const_real& ratio, const_real& angle, bool enabled )
            byte    getCustomBokeh( real& ratio, real& angle, bool& enabled )

            # Method:    set/getHide. sets/gets the hidden status of this camera (used only in Maxwell Studio)^M
            byte    setHide( bool hide )
            byte    isHide( bool& hide )

            # Method:    get/setUuid. Uuid that can be used for custom purposes^M
            byte    setUuid( const_char* pUuid )
            const_char* getUuid( )

            # Method:    get/setUserData  (Not used in plugins)^M
            byte    setUserData( void* pData )
            byte    getUserData( void** pData )

            # Method:    setActive. Sets the active camera used when rendering when there is more than one^M
            byte    setActive()

            # Method used internally in interactive mode (not used from outside)^M
            byte                setDirty( )
            byte                isDirty( bool& dirty )

            # Method:    free. Destroys the camera .return 0->failed, 1->success ( removed )^M
            byte    free()

            


        Cmaxwell(byte(*callback)(byte isError, const_char *pMethod, const_char *pError, const_void *pValue))
        byte readMXS(const_char* pPath, const_CoptionsReadMXS& mxsOptions)
        byte writeMXS(const_char* pPath)
        byte getSceneInfo(CsceneInfo& info)

        # Method: getEngineVersion. Returns the current version of Maxwell
        getEngineVersion(char pVersion[64])

        ###
        # Scene methods
        ###
        freeGeometry()
        freeScene()
        # Method: get/setScenePreview
        Crgb8* getSCenePreview( dword& xRes, dword& yRes)
        byte   setScebePreview( dword xRes, dword yRes, Crgb* pRGB)
        Crgb8* readPreview(const_char* pPath, dword& xResPreview, dword& yResPreview)




        # Method:    addCamera. Adds a new camera to the scene with the given parameters^M
        # projectionType:TYPE_PERSPECTIVE, TYPE_FRONT, TYPE_TOP, TYPE_LEFT, TYPE_BACK, TYPE_BOTTOM, TYPE_RIGHT^M 
        Ccamera addCamera( const_char* pName, dword nSteps, real shutter, real filmWidth, \
                           real filmHeight, real iso, const_char* pDiaphragmType, real angle, \
                           dword nBlades, dword fps, dword xRes, dword yRes, real pixelAspect, \
                           byte projectionType = 0)

        # Method:    getCamera. Given the name of a camera this function returns its Ccamera pointer.^M
        Ccamera getCamera( const_char* pCameraName )

        # Method:    getActiveCamera. Returns a pointer to the active camera of the scene^M
        Ccamera getActiveCamera()



cdef byte mwcallback(byte isError, const_char *pMethod, const_char *pError, const_void *pValue):
    print("{} {}".format(<char*>pMethod,<char*>pError))
    return isError
        
cdef class maxwell:
    cdef Cmaxwell *thisptr

    def __cinit__(self):
        self.thisptr = new Cmaxwell(mwcallback)

    def __dealloc__(self):
        del self.thisptr

    def readMXS(self, filename):
        cdef const_char* f = filename
        self.thisptr.readMXS(f, <const_CoptionsReadMXS>Cmaxwell.CoptionsReadMXS())

    def writeMXS(self, filename):
        cdef const_char* f = filename
        self.thisptr.writeMXS(f)

    def getSceneInfo(self):
        cdef Cmaxwell.CsceneInfo* info = new Cmaxwell.CsceneInfo()
        self.thisptr.getSceneInfo(deref(info))
        #print(info.nMeshes)
        nMeshes, nTriangles, nVertexes, nNormals, nMaterials, nBitmaps = info.nMeshes, info.nTriangles, info.nVertexes, info.nNormals, info.nMaterials, info.nBitmaps
        return [nMeshes, nTriangles, nVertexes, nNormals, nMaterials, nBitmaps]

    def getActiveCamera(self):         
        cdef Cmaxwell.Ccamera cam = self.thisptr.getActiveCamera()
        res = camera()
        res.thisptr = cam
        return res



cdef class point:
    cdef Cmaxwell.Cpoint *thisptr

    def __init__(self):
        self.thisptr = new Cvector()

    def __dealloc__(self):
        del self.thisptr

    def __str__(self):
        return "point [{} {} {}]".format(self.x,self.y, self.z )

    def __unicode__(self):
        return __str__(self)

    property x:
        def __get__(self): return self.thisptr.x
        def __set__(self, x): self.thisptr.x = x

    property y:
        def __get__(self): return self.thisptr.y
        def __set__(self, y): self.thisptr.y = y

    property z:
        def __get__(self): return self.thisptr.z
        def __set__(self, z): self.thisptr.z = z

cdef object _t_Point(Cpoint *p):
    res = point()
    del res.thisptr # till i find a better way to do things we have some double allocation going on
    res.thisptr = p
    return res


cdef class vector:
    cdef Cvector *thisptr

    def __init__(self):
        self.thisptr = new Cvector()

    def __dealloc__(self):
        del self.thisptr

    def __str__(self):
        return "vector: [{} {} {}]".format(self.x,self.y, self.z )

    def __unicode__(self):
        return __str__(self)

    def set(self, double x, double y, double z):
        self.thisptr.x = x
        self.thisptr.y = y
        self.thisptr.z = z

    property x:
        def __get__(self): return self.thisptr.x
        def __set__(self, x): self.thisptr.x = x

    property y:
        def __get__(self): return self.thisptr.y
        def __set__(self, y): self.thisptr.y = y

    property z:
        def __get__(self): return self.thisptr.z
        def __set__(self, z): self.thisptr.z = z

cdef object _t_Vector(Cvector *p):
    res = vector()
    del res.thisptr # till i find a better way to do things we have some double allocation going on
    res.thisptr = p
    return res

cdef class camera:
    cdef Cmaxwell.Ccamera thisptr

    def __cinit__(self):
        pass

    def __dealloc__(self):
        pass

    def setName(self, name):
        cdef const_char *c_string = name
        self.thisptr.setName(c_string)

    def getName(self):
        return self.thisptr.getName().decode('UTF-8')

    def setStep(self,dword iStep, point origin, point focalPoint, vector up, focalLength, fStop, stepTime, focalLengthNeedCorrection = True):
        cdef byte fLnC = 0 #focalLengthNeedCorrection
        cdef dword step = iStep
        cdef Cpoint o = deref(origin.thisptr)
        cdef Cpoint fP = deref(focalPoint.thisptr)
        cdef Cvector u = deref(up.thisptr)
        cdef real fL = focalLength
        cdef real fS = fStop
        cdef real sT = stepTime
        self.thisptr.setStep(step, o, fP, u, fL, fS, sT, fLnC )

    def getStep(self, dword iStep):
        cdef Cpoint *o = new Cpoint()
        cdef Cpoint *fP = new Cpoint()
        cdef Cvector *u = new Cvector()
        cdef real fL = 0
        cdef real fS = 0
        cdef real sT = 0
        self.thisptr.getStep( iStep, deref(o), deref(fP), deref(u), fL, fS, sT )
        return [_t_Point(o),_t_Point(fP),_t_Vector(u),fL,fS,sT]

    def setOrthoValues(self, dword iStep, real orthoX, real orthoY, real orthoZoom, real focalLength, real fStop ):
        self.thisptr.setOrthoValues( iStep,orthoX, orthoY, orthoZoom, focalLength, fStop )

    def getOrthoValues(self, dword iStep):
        cdef real orthoX = 0
        cdef real orthoY = 0
        cdef real orthoZoom = 0
        cdef real focalLength = 0
        cdef real fStop = 0
        self.thisptr.getOrthoValues( iStep, orthoX, orthoY, orthoZoom, focalLength, fStop )
        return [orthoX,orthoY,orthoZoom,focalLength,fStop]

    def setShiftLens(self, real xShift, real yShift):
        ''' Sets shift lens between -100 and 100 '''
        self.thisptr.setShiftLens(xShift,yShift)

    def getShiftLens(self):
        ''' Gets the shiftlens parameters '''
        cdef real xShift = 0
        cdef real yShift = 0
        self.thisptr.getShiftLens(xShift, yShift)
        return (xShift, yShift)

    #byte    setShiftLens( real xShift, real yShift )
        #byte    getShiftLens( real& xShift, real& yShift )

    #byte getOrthoValues( dword iStep, real& orthoX, real& orthoY, real& orthoZoom, real& focalLength, real& fStop )
    #const_char* getValues( dword& nSteps, real& shutter, real& filmWidth, real& filmHeight, real& iso,\
    #    const_char** pDiaphragmType, real& angle, dword& nBlades,\
    #    dword& fps, dword& xRes, dword& yRes, real& pixelAspect,\
    #    byte& projectionType )
    #byte setResolution( dword xRes, dword yRes )
    #byte getResolution( dword& xRes, dword& yRes )
    #byte setPixelAspect( real pixelAspect )
    #byte getPixelAspect( real& pixelAspect )

    #byte setShutter( real shutter )
    #byte getShutter( real& shutter )

    #byte setIso( real iso )
    #byte getIso( real& iso )

    #byte setFilmSize( real filmWidth, real filmHeight )
    #byte getFilmSize( real& filmWidth, real& filmHeight )

    #byte setDiaphragm( const_char* pDiaphragmType, real angle, dword nBlades )
    #byte getDiaphragm( const_char** pDiaphragmType, real& angle, dword& nBlades )

    #byte setFPS( real fps )
    #byte getFPS( real& fps )

    #byte setScreenRegion( dword x1, dword y1, dword x2, dword y2, const_char* pRegionType )
    #byte getScreenRegion( dword& x1, dword& y1, dword& x2, dword& y2, char* pType )

    #byte setCutPlanes( real zNear, real zFar, bool enabled )
    #byte getCutPlanes( real& zNear, real& zFar, bool& enabled )



    # Method:    get/setCustomBokeh.^M
    # Description: Defines a custom bokeh^M
    # Parameters: ^M
    #              ratio: aspect ratio (default: 1)^M
    #              angle: angle in radians^M
    #              enabled: sets the custom bokeh on/off^M
    #byte    setCustomBokeh( const_real& ratio, const_real& angle, bool enabled )
    #byte    getCustomBokeh( real& ratio, real& angle, bool& enabled )

    # Method:    set/getHide. sets/gets the hidden status of this camera (used only in Maxwell Studio)^M
    #byte    setHide( bool hide )
    #byte    isHide( bool& hide )

    # Method:    get/setUuid. Uuid that can be used for custom purposes^M
    #byte    setUuid( const_char* pUuid )
    #const_char* getUuid( )

    # Method:    get/setUserData  (Not used in plugins)^M
    #byte    setUserData( void* pData )
    #byte    getUserData( void** pData )

    # Method:    setActive. Sets the active camera used when rendering when there is more than one^M
    #byte    setActive()

    

