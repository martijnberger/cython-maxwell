from cython.operator cimport dereference as deref, preincrement as inc
from libc.string cimport const_char, const_void
from libc.stdlib cimport malloc, free

cimport cpython

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
        Cvector3DT[Cprecicion] origin
        Cvector3DT[Cprecicion] xAxis
        Cvector3DT[Cprecicion] yAxis
        Cvector3DT[Cprecicion] zAxis
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
    cdef cppclass MXparamList:
        pass
    ctypedef real const_real "const real"

    ctypedef unsigned char byte "byte"
    ctypedef int bool "bool"
    ctypedef void* const_CoptionsReadMXS "const Cmaxwell::CoptionsReadMXS"
    ctypedef byte const_byte "const byte"
    ctypedef dword const_dword "const dword"
    ctypedef bool const_bool "const bool"
    ctypedef void* const_Cobject "const Cmaxwell::Cobject"
    ctypedef void* const_Cpoint "const Cpoint"
    ctypedef void* const_Cvector "const Cvector"
    ctypedef void* const_Crgb "const Crgb"

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

            
        cppclass Cmaterial(Cpointer):
            cppclass Citerator:
                Citerator()
                Cmaterial first(Cmaxwell* pMaxwell)
                Cmaterial next()
            Cmaterial()
            Cmaterial createCopy()
            byte free()
            byte extract()
            byte getVersion(const_char* pFileName, float& version)
            byte setName(const_char* pFileName)
            const_char* getName()

        cppclass Cobject(Cpointer):
            cppclass Citerator:
                Citerator()
                Cobject first(Cmaxwell* pMaxwell)
                Cobject next()

            Cobject()
            byte setPointer( Cmaxwell* pMaxwell, void* pObject )
            byte free()
            byte getName(char** pName)
            byte setName(const_char* pName)

            # Method:    isMesh. Returns isMesh = 1 if this Cobject is a real mesh (not an instance or any other thing)
            byte isMesh( byte& isMesh )

            # Method:    isInstance. Returns isInstance = 1 if this Cobject is an instance, otherwise returns 0.
            byte isInstance( byte& isInstance )

            # Method:    getInstanced. If this Cobject is an instance this method returns its parent object
            Cobject getInstanced()

            # Method:    isRFRK. Returns isRfrk = 1 if this Cobject is a RealFlow particles object, otherwise returns 0.
            byte isRFRK( byte& isRfrk )

            # Method:    getRFRKParameters
            byte getRFRKParameters( char*& binSeqNames, char*& rwName, char*& substractiveField, \
                            real& scale, real& resolution, real& polySize, real& radius, real& smooth, real& core, \
                            real& splash, real& maxVelocity, int& axis, real& fps, int& frame, int& offset, bool& f, \
                            int& rwTesselation, bool& mb, real& mbCoef )


            byte setRFRKParameters( const_char* binSeqNames, const_char* rwName, char* substractiveField, \
                                real scale, real resolution, real polySize, real radius, real smooth, real core, \
                                real splash, real maxVelocity, int axis, real fps, int frame, int offset, bool flipNorm, \
                                int rwTesselation, bool mb, real mbCoef )

            # Method:    get/setProxyPath. Get/sets the scene file referenced by this object
            const_char* getReferencedScenePath()
            byte setReferencedScenePath( const_char* proxyPath )

            # Method:    get/setReferenceMaterial. Get/sets the material of an specific object inside the referenced scene
            byte getReferencedSceneMaterial( const_char* objectName, Cmaterial& material )
            byte setReferencedSceneMaterial( const_char* objectName, Cmaterial material )

            # Method: get/setReferencedOverrideFlags. Get the override policy for visibility flags
            # flags are described in OVERRIDE_REFERENCE_FLAGS in maxwellenums.h
            byte getReferencedOverrideFlags( byte& flags )
            byte setReferencedOverrideFlags( const_byte& flags )

            # Method:    mergeMeshes
            # Description: Merges an array of meshes into a single mesh.
            # The original meshes are not removed (it can be done later calling Cobject::free() ).
            byte    mergeMeshes( const_Cobject* pMeshes, dword nMeshes )

            # Method:    get/setParent. Get/sets the parent object in the hierarchy
            byte    getParent( Cobject& parent )
            byte    setParent( Cobject parent )

            # Method:    get/setUuid. Uuid that can be used for custom purposes
            const_char* getUuid( )
            byte    setUuid( const_char* pUuid )

            # Method:    get/setMaterial. Material applied to the object
            byte    getMaterial( Cmaterial& material )
            byte    setMaterial( Cmaterial material )

            # Method:    get/setProperties. Caustics properties of the object
            byte    getProperties( byte& doDirectCausticsReflection, byte& doDirectCausticsRefraction, \
                                   byte& doIndirectCausticsReflection, byte& doIndirectCausticsRefraction )
            byte    setProperties( byte doDirectCausticsReflection, byte doDirectCausticsRefraction, \
                                   byte doIndirectCausticsReflection, byte doIndirectCausticsRefraction )

            byte  getDependencies( dword& numDependencies, char** & paths, const_bool& searchInsideProxy )

            # Method:    getters/setters to set the mesh properties of the Cobject
            byte    getNumVertexes( dword& nVertexes )
            byte    getNumTriangles( dword& nTriangles )
            byte    getNumNormals( dword& nNormals )
            byte    getNumPositionsPerVertex( dword& nPositions )
            byte    getNumChannelsUVW( dword& nChannelsUVW )

            byte    addChannelUVW( dword& index, byte id)
            byte    generateSphericalUVW( dword& iChannel, Cbase& projectorBase, \
                                          real& startLatitude, real& endLatitude, \
                                          real& startLongitude, real& endLongitude )
            byte    generateCylindricalUVW( dword& iChannel, Cbase& projectorBase, \
                                            real& startAngle, real& endAngle )
            byte    generateCubicUVW( dword& iChannel, Cbase& projectorBase, bool mirrorBackFaces)
            byte    generatePlanarUVW( dword& iChannel, Cbase& projectorBase )


            byte    getVertex( dword iVertex, dword iPosition, Cpoint& point )
            byte    setVertex( dword iVertex, dword iPosition, const_Cpoint& point )

            byte    getNormal( dword iNormal, dword iPosition, Cvector& normal )
            byte    setNormal( dword iNormal, dword iPosition, const_Cvector& normal )

            byte    getTriangle( dword iTriangle, dword& iVertex1, dword& iVertex2, dword& iVertex3, \
                                 dword& iNormal1, dword& iNormal2, dword& iNormal3 )
            byte    setTriangle( dword iTriangle, dword iVertex1, dword iVertex2, dword iVertex3, \
                                 dword iNormal1, dword iNormal2, dword iNormal3 )

            byte    getTriangleGroup( dword iTriangle, dword& idGroup )
            byte    setTriangleGroup( dword iTriangle, dword idGroup )

            byte    getTriangleUVW( dword iTriangle, dword iChannelID, float& u1, float& v1, float& w1, \
                                    float& u2, float& v2, float& w2, float& u3, float& v3, float& w3 )
            byte    setTriangleUVW( dword iTriangle, dword iChannelID, float u1, float v1, float w1, \
                                    float u2, float v2, float w2, float u3, float v3, float w3 )

            byte    getTriangleMaterial( dword iTriangle, Cmaterial& material )
            byte    setTriangleMaterial( dword iTriangle, Cmaterial material )

            byte    getGroupMaterial( dword iGroup, Cmaterial& material )
            byte    setGroupMaterial( dword iGroup, Cmaterial material )

            byte    setBaseAndPivot( Cbase base, Cbase pivot, real substepTime)
            byte    getBaseAndPivot( Cbase& base, Cbase& pivot, const_real substepTime)

            # Method: getWorldTransform
            # Description: Returns the world transform of the object
            # taking into account base and pivot of all its parents
            byte    getWorldTransform( Cbase& base )

            # Method: getTransformSubstepsCount
            # Description: Return the number of substeps used for defining Base and Pivot motion blur
            dword   getTransformSubstepsCount( )

            # Method: getTransformSubstepsCount
            # Description: Return transform information( base, pivot and time) for the given index
            byte    getTransformStepInfoByIndex( Cbase& base, Cbase& pivot, real& time, const_dword index )

            #Global base, assumes global pivot is located at 0,0,0 and
            #with pivot axis 1,0,0  0,1,0   0,0,1

            # Method:    get/set position/rotation/scale/shear
            # Description: Used by Maxwell Studio (not needed for rendering)
            # isPosRotScaleInitialized returns true by reference if these methods have been used for the given Cobject
            byte    getPosition( Cvector& vector )
            byte    setPosition( Cvector vector )

            byte    getRotation( Cvector& vector )
            byte    setRotation( Cvector vector )

            byte    getScale( Cvector& vector )
            byte    setScale( Cvector vector )

            byte    getShear( Cvector& vector )
            byte    setShear( Cvector vector )

            byte    getPivotPosition( Cvector& vector )
            byte    setPivotPosition( Cvector vector )

            byte    getPivotRotation( Cvector& vector )
            byte    setPivotRotation( Cvector vector )

            byte    isPosRotScaleInitialized( bool& init )

            # Method:    cleanGeometry
            # Description: Optional routine that removes degenerated triangles, repeated/unused vertex and normals.
            # This function is automatically called inside the writeMXS method
            # it is not needed to call it except in scenarios like the interactive engine
            byte    cleanGeometry()

            #
            # DISPLAY FUNCTIONS. Getters/setters of visibility attributes of  Cobject
            #
            byte getHide( bool& hide )
            byte setHide( bool hide )

            byte getHideToCamera( bool& hide )
            byte setHideToCamera( bool hide )

            byte getHideToReflectionsRefractions( bool& hide )
            byte setHideToReflectionsRefractions( bool hide )

            byte getHideToGI( bool& hide )
            byte setHideToGI( bool hide )

            byte isExcludedOfCutPlanes( bool& excluded )
            byte excludeOfCutPlanes( bool exclude )

            float* getReferenceProxyDisplayPoints( const_dword& percent, const_dword& maxPoints, dword& nPoints )

            # Method:    get/setColorID
            # Description: gets/sets the color used by this object in the Object ID render channel
            # rgb values must always be in the 0-1 range
            byte setColorID( const_Crgb& color )
            byte getColorID( Crgb& color )

            # Method:    get/setSubdivisionLevel
            # Description: gets/sets the subdivision level of the mesh
            # 0 means no subdivision is applied
            byte setSubdivisionLevel( const_dword& level )
            byte getSubdivisionLevel( dword& level )


            # Method used to recalculate structures needed in interactive mode when the object changes
            # It is not needed to call it if the UVs or material change,
            # but just should be called when the mesh or base change.
            byte setGeometryDirty( )

            # Method:    get/setUserData  (Not used in plugins)
            byte getUserData( void** pData )
            byte setUserData( void* pData ) #// [Not used by plugins]

            #// Method:  Buffer accessors (Not used in plugins)
            CfPoint* getVertexesBuffer( )
            CfPoint* getNormalsBuffer( )

            byte initializeMesh ( dword nVertex, dword nNormals, dword nFaces, dword positionsPerVertex )
            #This function reinitializes all the basic geometry and UV arrays.
            #The number of UV channels and their ids remain the same, but UV´s are zeroed
            #Motion blur vertices can be wiped (if there were) setting newNpositionsPerVertex = 1
            #or added (if there weren´t) setting newNpositionsPerVertex = 2
            byte resizeMesh( dword newNVertex, dword newNNormals, dword newNFaces, dword newNpositionsPerVertex )

            byte    generateCustomUVW( dword iChannel, dword iGeneratorType )

            byte    getUVWChannelProperties( dword iChannel, byte& projType, bool& customProj, \
                                             Cbase& projectorBase, \
                                             real& startLatitude, real& endLatitude, \
                                             real& startLongitude, real& endLongitude, \
                                             real& startAngle, real& endAngle, bool& mirrorBackFaces )

            byte    getGlobalXform( Cbase& xForm )
            byte    getGlobalNormalsXform( Cbase& nXform )
            byte    getInverseGlobalXform( Cbase& ixForm )
            byte    getInverseGlobalNormalsXform( Cbase& inXform )

            byte isGeometryLoader( byte& isGeomExtension )
            byte isGeometryProcedural( byte& isGeomProceduralExtension )
            byte hasGeometryModifiers( byte& hasGeomModifierExtensions )

            byte applyGeometryModifierExtension( MXparamList*& extensionParams )
            byte cleanAllGeometryModifierExtensions()

            byte getGeometryLoaderExtensionParams( MXparamList*& extensionParams )
            byte getGeometryProceduralExtensionParams( MXparamList*& extensionParams )

            byte getGeometryModifierExtensionsNumber( dword& numModifierExtensions )
            byte getGeometryModifierExtensionParamsAtIndex( MXparamList*& extensionParams, dword modifierExtensionsIndex )


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






    

