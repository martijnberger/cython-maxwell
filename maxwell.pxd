# -*- coding: utf-8 -*-

from vectors cimport *
from base cimport *
from color cimport *

cdef extern from "h/flags.h":
    cdef cppclass Cflags[Cprecision]:
        Cflags()

cdef extern from "h/maxwell.h":
    enum material_blendering_modes "Cmaxwell::Cmaterial::BLENDING_MODES":
        BLENDING_NORMAL
        BLENDING_ADDITIVE

    cdef cppclass MXparamList:
        pass

    ctypedef unsigned char byte "byte"
    ctypedef int bool "bool"

    cdef cppclass Cmaxwell:
        cppclass Cpointer:
            Cpointer()
            bool isNull()
            void* getPointer()

        cppclass CmultiValue:
            #const char* pID
            #const char* pType
            #void* pParameter
            CmultiValue(const char* _pID, const char* _pType, void* _pParameter)

            cppclass Cmap:
                byte        type
                real        value
                Crgb        rgb

                char*       pFileName
                Cpoint2D    scale
                Cpoint2D    offset
                dword       uvwChannel
                byte        typeInterpolation
                byte        uIsTiled
                byte        vIsTiled
                byte        invert
                byte        doGammaCorrection
                byte        useAbsoluteUnits
                byte        normalMappingFlipRed
                byte        normalMappingFlipGreen
                byte        normalMappingFullRangeBlue
                byte        useAlpha
                float       saturation # // range: [-1.0, 1.0]
                float       contrast #   // range: [-1.0, 1.0]
                float       brightness # // range: [-1.0, 1.0]
                float       clampMin #   // range: [0.0, 1.0]
                float       clampMax #   // range: [0.0, 1.0]
                #CextensionList     extensionList;
                Cmap( )


        cppclass CmaterialPointer(Cpointer):
            CmaterialPointer()

        cppclass Creflectance(CmaterialPointer):
            Creflectance()

            byte setActiveIorMode( byte complex )
            byte getActiveIorMode( byte& complex )

            byte setComplexIor( const char* pFileName )
            const char* getComplexIor( )

            byte getColor( const char* pID, Cmaxwell.CmultiValue.Cmap& map )
        cppclass Cbsdf(CmaterialPointer):
            Cbsdf()
            byte    setName( const char* pName )
            char*   getName( )

            byte    setState( bool enabled )
            byte    getState( bool& enabled )

            byte    setWeight( Cmaxwell.CmultiValue.Cmap& map )
            byte    getWeight( Cmaxwell.CmultiValue.Cmap& map )
            byte    setActiveWeight( Cmaxwell.CmultiValue.Cmap& map )
            byte    getActiveWeight( Cmaxwell.CmultiValue.Cmap& map )
            Cmaxwell.Creflectance  getReflectance( )


        cppclass CoptionsReadMXS(Cflags):
            CoptionsReadMXS()

        cppclass CsceneInfo:
            dword nMeshes, nTriangles, nVertexes, nNormals, nMaterials, nBitmaps
            CsceneInfo()

        cppclass CmaterialEmitter(CmaterialPointer):
            CmaterialEmitter()

        cppclass CmaterialLayer(CmaterialPointer):
            CmaterialLayer()
            byte    setEnabled( bool enable )
            byte    getEnabled( bool& enabled )

            byte    setName( const char* pName )
            byte    getName( char** pName )

            byte    setStackedBlendingMode( byte mode )
            byte    getStackedBlendingMode( byte& mode )

            byte    setWeight( Cmaxwell.CmultiValue.Cmap& map )
            byte    getWeight( Cmaxwell.CmultiValue.Cmap& map )

            byte    setActiveWeight( Cmaxwell.CmultiValue.Cmap& map )
            byte    getActiveWeight( Cmaxwell.CmultiValue.Cmap& map )

            Cmaxwell.CmaterialEmitter    createEmitter( )
            Cmaxwell.CmaterialEmitter    getEmitter( )
            byte                freeEmitter( )

            byte        enableDisplacement( bool enable )
            byte        isDisplacementEnabled( bool& enabled )

            byte        setDisplacementMap( Cmaxwell.CmultiValue.Cmap& map )
            byte        getDisplacementMap( Cmaxwell.CmultiValue.Cmap& map )

            byte        setDisplacementCommonParameters( byte displacementType, real subdivisionLevel, real smoothness, dword minLOD = 0, dword maxLOD = 0 )
            byte        getDisplacementCommonParameters( byte& displacementType, real& subdivisionLevel, real& smoothness, dword& minLOD, dword& maxLOD )

            byte        setHeightMapDisplacementParameters( real offset, real height, bool absoluteHeight, bool adaptive )
            byte        getHeightMapDisplacementParameters( real& offset, real& height, bool& absoluteHeight, bool& adaptive )

            byte        setVectorDisplacementParameters( Cvector scale )
            byte        getVectorDisplacementParameters( Cvector& scale )

            Cmaxwell.Cbsdf   addBSDF( )
            byte    getNumBSDFs( byte& nBSDFs )
            Cmaxwell.Cbsdf   getBSDF( byte index )

            void setAttribute( const char* name, const Cmaxwell.CmultiValue.Cmap& map )
            void setActiveAttribute( const char* name, const Cmaxwell.CmultiValue.Cmap& map )

            byte getAttribute( const char* name, Cmaxwell.CmultiValue.Cmap& map )
            byte getActiveAttribute( const char* name, Cmaxwell.CmultiValue.Cmap& map )





        cppclass CmultiValue:
            const char* pID
            const char* pType
            void* pParameter
            CmultiValue(const char* _pID, const char* _pType, void* _pParameter)
            cppclass Cmap:
                byte type
                real value
                Crgb rgb
                Cmap()

        cppclass Ccamera(Cpointer):
            cppclass Citerator:
                Citerator()
                Cmaxwell.Ccamera first(Cmaxwell* pMaxwell)
                Cmaxwell.Ccamera next()
            Ccamera()
            byte setStep(dword iStep, Cpoint origin, Cpoint focalPoint, Cvector up, real focalLength, real fStop, real stepTime, byte focalLengthNeedCorrection )
            byte getStep( dword iStep, Cpoint& origin, Cpoint& focalPoint, Cvector& up, real& focalLength, real& fStop, real& stepTime )
            byte setOrthoValues( dword iStep, real orthoX, real orthoY, real orthoZoom, real focalLength, real fStop )
            byte getOrthoValues( dword iStep, real& orthoX, real& orthoY, real& orthoZoom, real& focalLength, real& fStop )
            const char* getValues( dword& nSteps, real& shutter, real& filmWidth, real& filmHeight, real& iso,
                                   const char** pDiaphragmType, real& angle, dword& nBlades,
                                   dword& fps, dword& xRes, dword& yRes, real& pixelAspect,
                                   byte& projectionType )
            byte setName( const char* pName )
            const char* getName()
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

            byte setDiaphragm( const char* pDiaphragmType, real angle, dword nBlades )
            byte getDiaphragm( const char** pDiaphragmType, real& angle, dword& nBlades )

            byte setFPS( real fps )
            byte getFPS( real& fps )

            byte setScreenRegion( dword x1, dword y1, dword x2, dword y2, const char* pRegionType )
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
            byte    setCustomBokeh( const real& ratio, const real& angle, bool enabled )
            byte    getCustomBokeh( real& ratio, real& angle, bool& enabled )

            # Method:    set/getHide. sets/gets the hidden status of this camera (used only in Maxwell Studio)^M
            byte    setHide( bool hide )
            byte    isHide( bool& hide )

            # Method:    get/setUuid. Uuid that can be used for custom purposes^M
            byte    setUuid( const char* pUuid )
            const char* getUuid( )

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
                Cmaxwell.Cmaterial first(Cmaxwell* pMaxwell)
                Cmaxwell.Cmaterial next()
            Cmaterial()

            Cmaxwell.Cmaterial createCopy()
            byte free()
            byte extract()
            byte getVersion(const char* pFileName, float& version)

            byte setName(const char* pFileName)
            const char* getName()

            byte setReference( const byte& enabled, const char* mxmPath )
            const char* getReference( byte& enabled )

            byte setDescription( const char* pDescription )
            const char* getDescription( )

            byte setUuid( const char* pUuid )
            const char* getUuid( )

            byte setDirty()
            byte isDirty( bool& dirty )

            byte forceToWriteIntoScene()
            byte belongToScene( bool& belong )

            byte isEmpty( byte& empty )
            byte setEmpty( )

            byte read( const char* pFileName )
            byte write( const char* pFileName )

            byte setDispersion( bool enabled )
            byte getDispersion( bool& enabled )

            byte setMatte( bool enabled )
            byte getMatte( bool& enabled )

            byte setMatteShadow( bool enabled )
            byte getMatteShadow( bool& enabled )

            Cmaxwell.CmaterialLayer addLayer( )
            byte getNumLayers( byte& nLayers )
            Cmaxwell.CmaterialLayer getLayer( byte index )

            byte setLayerDisplacement( dword index )
            byte getLayerDisplacement( dword& index, bool& displacementOk )

            byte setColor( const char* pID, Cmaxwell.CmultiValue.Cmap& map )
            byte getColor( const char* pID, Cmaxwell.CmultiValue.Cmap& map )

            byte setActiveColor( const char* pID, Cmaxwell.CmultiValue.Cmap& map )
            byte getActiveColor( const char* pID, Cmaxwell.CmultiValue.Cmap& map )

            byte setNormalMapState( bool enabled )
            byte getNormalMapState( bool& enabled )

            byte setColorID( const Crgb& color )
            byte getColorID( Crgb& color )

            # XXX TODO preview functions (line 434 onwards


        cppclass Cobject(Cpointer):
            cppclass Citerator:
                Citerator()
                Cmaxwell.Cobject first(Cmaxwell* pMaxwell)
                Cmaxwell.Cobject next()

            Cobject()
            byte setPointer( Cmaxwell* pMaxwell, void* pObject )
            byte free()
            byte getName(char** pName)
            byte setName(const char* pName)

            # Method:    isMesh. Returns isMesh = 1 if this Cobject is a real mesh (not an instance or any other thing)
            byte isMesh( byte& isMesh )

            # Method:    isInstance. Returns isInstance = 1 if this Cobject is an instance, otherwise returns 0.
            byte isInstance( byte& isInstance )

            # Method:    getInstanced. If this Cobject is an instance this method returns its parent object
            Cmaxwell.Cobject getInstanced()

            # Method:    isRFRK. Returns isRfrk = 1 if this Cobject is a RealFlow particles object, otherwise returns 0.
            byte isRFRK( byte& isRfrk )

            # Method:    getRFRKParameters
            byte getRFRKParameters( char*& binSeqNames, char*& rwName, char*& substractiveField,
                            real& scale, real& resolution, real& polySize, real& radius, real& smooth, real& core,
                            real& splash, real& maxVelocity, int& axis, real& fps, int& frame, int& offset, bool& f,
                            int& rwTesselation, bool& mb, real& mbCoef )


            byte setRFRKParameters( const char* binSeqNames, const char* rwName, char* substractiveField,
                                real scale, real resolution, real polySize, real radius, real smooth, real core,
                                real splash, real maxVelocity, int axis, real fps, int frame, int offset, bool flipNorm,
                                int rwTesselation, bool mb, real mbCoef )

            # Method:    get/setProxyPath. Get/sets the scene file referenced by this object
            const char* getReferencedScenePath()
            byte setReferencedScenePath( const char* proxyPath )

            # Method:    get/setReferenceMaterial. Get/sets the material of an specific object inside the referenced scene
            byte getReferencedSceneMaterial( const char* objectName, Cmaxwell.Cmaterial& material )
            byte setReferencedSceneMaterial( const char* objectName, Cmaxwell.Cmaterial material )

            # Method: get/setReferencedOverrideFlags. Get the override policy for visibility flags
            # flags are described in OVERRIDE_REFERENCE_FLAGS in maxwellenums.h
            byte getReferencedOverrideFlags( byte& flags )
            byte setReferencedOverrideFlags( const byte& flags )

            # Method:    mergeMeshes
            # Description: Merges an array of meshes into a single mesh.
            # The original meshes are not removed (it can be done later calling Cobject::free() ).
            byte    mergeMeshes( const Cmaxwell.Cobject* pMeshes, dword nMeshes )

            # Method:    get/setParent. Get/sets the parent object in the hierarchy
            byte    getParent( Cmaxwell.Cobject& parent )
            byte    setParent( Cmaxwell.Cobject parent )

            # Method:    get/setUuid. Uuid that can be used for custom purposes
            const char* getUuid( )
            byte    setUuid( const char* pUuid )

            # Method:    get/setMaterial. Material applied to the object
            byte    getMaterial( Cmaxwell.Cmaterial& material )
            byte    setMaterial( Cmaxwell.Cmaterial material )

            # Method:    get/setProperties. Caustics properties of the object
            byte    getProperties( byte& doDirectCausticsReflection, byte& doDirectCausticsRefraction,
                                   byte& doIndirectCausticsReflection, byte& doIndirectCausticsRefraction )
            byte    setProperties( byte doDirectCausticsReflection, byte doDirectCausticsRefraction,
                                   byte doIndirectCausticsReflection, byte doIndirectCausticsRefraction )

            byte  getDependencies( dword& numDependencies, char** & paths, const bool& searchInsideProxy )

            # Method:    getters/setters to set the mesh properties of the Cobject
            byte    getNumVertexes( dword& nVertexes )
            byte    getNumTriangles( dword& nTriangles )
            byte    getNumNormals( dword& nNormals )
            byte    getNumPositionsPerVertex( dword& nPositions )
            byte    getNumChannelsUVW( dword& nChannelsUVW )

            byte    addChannelUVW( dword& index, byte id)
            byte    generateSphericalUVW( dword& iChannel, Cbase& projectorBase,
                                          real& startLatitude, real& endLatitude,
                                          real& startLongitude, real& endLongitude )
            byte    generateCylindricalUVW( dword& iChannel, Cbase& projectorBase,
                                            real& startAngle, real& endAngle )
            byte    generateCubicUVW( dword& iChannel, Cbase& projectorBase, bool mirrorBackFaces)
            byte    generatePlanarUVW( dword& iChannel, Cbase& projectorBase )


            byte    getVertex( dword iVertex, dword iPosition, Cpoint& point )
            byte    setVertex( dword iVertex, dword iPosition, const Cpoint& point )

            byte    getNormal( dword iNormal, dword iPosition, Cvector& normal )
            byte    setNormal( dword iNormal, dword iPosition, const Cvector& normal )

            byte    getTriangle( dword iTriangle, dword& iVertex1, dword& iVertex2, dword& iVertex3,
                                 dword& iNormal1, dword& iNormal2, dword& iNormal3 )
            byte    setTriangle( dword iTriangle, dword iVertex1, dword iVertex2, dword iVertex3,
                                 dword iNormal1, dword iNormal2, dword iNormal3 )

            byte    getTriangleGroup( dword iTriangle, dword& idGroup )
            byte    setTriangleGroup( dword iTriangle, dword idGroup )

            byte    getTriangleUVW( dword iTriangle, dword iChannelID, float& u1, float& v1, float& w1,
                                    float& u2, float& v2, float& w2, float& u3, float& v3, float& w3 )
            byte    setTriangleUVW( dword iTriangle, dword iChannelID, float u1, float v1, float w1,
                                    float u2, float v2, float w2, float u3, float v3, float w3 )

            byte    getTriangleMaterial( dword iTriangle, Cmaxwell.Cmaterial& material )
            byte    setTriangleMaterial( dword iTriangle, Cmaxwell.Cmaterial material )

            byte    getGroupMaterial( dword iGroup, Cmaxwell.Cmaterial& material )
            byte    setGroupMaterial( dword iGroup, Cmaxwell.Cmaterial material )

            byte    setBaseAndPivot( Cbase base, Cbase pivot, real substepTime)
            byte    getBaseAndPivot( Cbase& base, Cbase& pivot, const real substepTime)

            # Method: getWorldTransform
            # Description: Returns the world transform of the object
            # taking into account base and pivot of all its parents
            byte    getWorldTransform( Cbase& base )

            # Method: getTransformSubstepsCount
            # Description: Return the number of substeps used for defining Base and Pivot motion blur
            dword   getTransformSubstepsCount( )

            # Method: getTransformSubstepsCount
            # Description: Return transform information( base, pivot and time) for the given index
            byte    getTransformStepInfoByIndex( Cbase& base, Cbase& pivot, real& time, const dword index )

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

            float* getReferenceProxyDisplayPoints( const dword& percent, const dword& maxPoints, dword& nPoints )

            # Method:    get/setColorID
            # Description: gets/sets the color used by this object in the Object ID render channel
            # rgb values must always be in the 0-1 range
            byte setColorID( const Crgb& color )
            byte getColorID( Crgb& color )

            # Method:    get/setSubdivisionLevel
            # Description: gets/sets the subdivision level of the mesh
            # 0 means no subdivision is applied
            byte setSubdivisionLevel( const dword& level )
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

            byte    getUVWChannelProperties( dword iChannel, byte& projType, bool& customProj,
                                             Cbase& projectorBase,
                                             real& startLatitude, real& endLatitude,
                                             real& startLongitude, real& endLongitude,
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


        Cmaxwell(byte(*callback)(byte isError, const char *pMethod, const char *pError, const void *pValue))
        byte readMXS(const char* pPath, const CoptionsReadMXS& mxsOptions)
        byte writeMXS(const char* pPath)
        byte getSceneInfo(Cmaxwell.CsceneInfo& info)

        # Method: getEngineVersion. Returns the current version of Maxwell
        getEngineVersion(char pVersion[64])

        ###
        # Scene methods
        ###
        freeGeometry()
        void freeScene()
        # Method: get/setScenePreview
        Crgb8* getSCenePreview( dword& xRes, dword& yRes)
        byte   setScebePreview( dword xRes, dword yRes, Crgb* pRGB)
        Crgb8* readPreview(const char* pPath, dword& xResPreview, dword& yResPreview)




        # Method:    addCamera. Adds a new camera to the scene with the given parameters^M
        # projectionType:TYPE_PERSPECTIVE, TYPE_FRONT, TYPE_TOP, TYPE_LEFT, TYPE_BACK, TYPE_BOTTOM, TYPE_RIGHT^M 
        Cmaxwell.Ccamera addCamera( const char* pName, dword nSteps, real shutter, real filmWidth,
                           real filmHeight, real iso, const char* pDiaphragmType, real angle,
                           dword nBlades, dword fps, dword xRes, dword yRes, real pixelAspect,
                           byte projectionType)

        # Method:    getCamera. Given the name of a camera this function returns its Ccamera pointer.^M
        Cmaxwell.Ccamera getCamera( const char* pCameraName )

        # Method:    getActiveCamera. Returns a pointer to the active camera of the scene^M
        Cmaxwell.Ccamera getActiveCamera()

        byte setRenderParameter( const char* pParameterName, dword size, const void* pParameterValue )
        byte getRenderParameter( const char* pParameterName, dword size, void* pParameterValue )

        Cmaxwell.Cobject  getObject( const char* pObjectName )

        Cmaxwell.Cmaterial addMaterial( Cmaxwell.Cmaterial& material )

        Cmaxwell.Cmaterial getMaterial( const char* pMaterialName )

        Cmaxwell.Cobject     addObject( Cmaxwell.Cobject& object )

        Cmaxwell.Cobject createMesh( const char* pName, dword nVertexes, dword nNormals, dword nTriangles, dword nPositionsPerVertex )

        Cmaxwell.Cobject createInstancement( const char* pName, Cmaxwell.Cobject& object )

        byte setPath( const char* pType, const char* pPath, byte& outputBitDepthMode )
        const char*  getPath( const char* pType, byte& outputBitDepthMode )

        byte addSearchingPath( const char* pPath)

        byte getSearchingPaths( dword& numPaths, char** & paths )

        #0: Latitude / Longitude
        #1: Angles (zenith /azimuth)
        #2: Direction (vector)
        byte getSunPositionType( byte& positionType )
        byte setSunPositionType( const byte& positionType )

        Cmaxwell.Cmaterial readMaterial( const char* pFileName )

        




    

