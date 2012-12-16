# -*- coding: utf-8 -*-

from cython.operator cimport dereference as deref, preincrement as inc
from libc.string cimport const_char, const_void
from libc.stdlib cimport malloc, free

from maxwell cimport *

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

    def getObjectIterator(self):
        #return ObjectIterator(self)
        cdef Cmaxwell.Cobject.Citerator it
        cdef Cmaxwell.Cobject o = it.first(self.thisptr)
        while o.isNull() == <byte>0:
            yield _t_Object_from_pointer(self.thisptr, <Cmaxwell.Cobject *>o.getPointer())
            o = it.next()

    #broken need a way to get the actual object pointer
    def getMaterialsIterator(self):
        #    #return ObjectIterator(self)
        cdef Cmaxwell.Cmaterial.Citerator it
        cdef Cmaxwell.Cmaterial m = it.first(self.thisptr)
        while m.isNull() == <byte>0:
            yield _t_Material(m)
            m = it.next()




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


cdef class Vector:
    cdef Cvector *thisptr
    cdef bool __skipfree

    def __cinit__(self, __skipfree=False):
        self.thisptr = new Cvector()
        self.__skipfree = __skipfree

    def __init__(self, __skipfree=False):
        self.thisptr = new Cvector()
        self.__skipfree = __skipfree

    def __dealloc__(self):
        if not self.__skipfree:
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


cdef object _t_Vector(Cvector *p, __skipfree=False):
    res = Vector(__skipfree=__skipfree)
    del res.thisptr # till i find a better way to do things we have some double allocation going on
    res.thisptr = p
    return res


cdef class Base:
    cdef Cbase *thisptr

    def __cinit__(self, __skip_creation=False):
        if not __skip_creation:
            self.thisptr = new Cbase()

    def __init__(self, __skip_creation=False):
        if not __skip_creation:
            self.thisptr = new Cbase()

    def __dealloc__(self):
        del self.thisptr

    def set(self, Vector origin, Vector x, Vector y, Vector z):
        self.thisptr.origin

    def __str__(self):
        return "Base : origin: {} {} {}".format(self.origin.x,self.origin.y,self.origin.z)

    property origin:
        def __get__(self): return _t_Vector(&self.thisptr.origin,True)
        def __set__(self, Vector origin):
            self.thisptr.origin.x = origin.x
            self.thisptr.origin.y = origin.y
            self.thisptr.origin.z = origin.z

    property x:
        def __get__(self): return _t_Vector(&self.thisptr.xAxis,True)
        def __set__(self, Vector x):
            self.thisptr.xAxis.x = x.x
            self.thisptr.xAxis.y = x.y
            self.thisptr.xAxis.z = x.z

    property y:
        def __get__(self): return _t_Vector(&self.thisptr.yAxis,True)
        def __set__(self, Vector y):
            self.thisptr.yAxis.x = y.x
            self.thisptr.yAxis.y = y.y
            self.thisptr.yAxis.z = y.z

    property z:
        def __get__(self): return _t_Vector(&self.thisptr.zAxis,True)
        def __set__(self, Vector z): self.thisptr.zAxis = deref(z.thisptr)


cdef object _t_Base(Cbase *p):
    res = Base(__skip_creation=True)
    res.thisptr = p
    return res


cdef class Object:
    cdef Cmaxwell.Cobject *thisptr
    cdef Cmaxwell *sceneptr

    def __cinit__(self):
        pass

    def __dealloc__(self):
        pass

    cdef setPointer(self,Cmaxwell * m, void* p):
        self.thisptr = new Cmaxwell.Cobject()
        self.sceneptr = m
        self.thisptr.setPointer(m,p)

    #def free(self):
    #    self.thisptr.free()

    def setName(self, name):
        cdef const_char *c_string = name
        self.thisptr.setName(c_string)

    def getName(self):
        cdef char* name
        self.thisptr.getName(&name)
        res = name.decode('UTF-8')
        return res

    def isMesh(self):
        cdef byte res = 0
        self.thisptr.isMesh(res)
        return res

    def isInstance(self):
        cdef byte res = 0
        self.thisptr.isInstance(res)
        return res

    def getInstanced(self):
        res = self.thisptr.getInstanced()
        return _t_Object_from_pointer(self.sceneptr,  res.getPointer())

    def isRFRK(self):
        # Method:    isRFRK. Returns isRfrk = 1 if this Cobject is a RealFlow particles object, otherwise returns 0.
        cdef byte res = 0
        res = self.thisptr.isRFRK(res)
        return res

    def isNull(self):
        return self.thisptr.isNull()

    # Method:    get/setProxyPath. Get/sets the scene file referenced by this object
    def getReferencedScenePath(self):
        return self.thisptr.getReferencedScenePath().decode('UTF-8')

    def setReferencedScenePath(self, const_char* proxyPath):
        res = self.thisptr.setReferencedScenePath(proxyPath)

    def getParent(self):
        cdef Cmaxwell.Cobject p
        cdef Cmaxwell.Cobject* p_p
        bv = self.thisptr.getParent(p)
        p_p = <Cmaxwell.Cobject *>p.getPointer()
        if <size_t>p_p != 0 and p_p.isNull() == 0:
            res = _t_Object_from_pointer(self.sceneptr, p_p)
            return res
        else:
            return False

    def setParent(self,Object parent):
        self.thisptr.setParent(deref(parent.thisptr))
        pass


    # Method:    getters/setters to set the mesh properties of the Cobject
    def getNumVertexes(self):
        cdef dword nVertexes = 0
        self.thisptr.getNumVertexes(nVertexes)
        return nVertexes

    def getNumTriangles(self):
        cdef dword nTriangles = 0
        res = self.thisptr.getNumTriangles( nTriangles )
        return res

    def getNumNormals(self):
        cdef dword nNormals = 0
        res = self.thisptr.getNumNormals( nNormals )
        return res

    def getNumPositionsPerVertex(self):
        cdef dword nPositions = 0
        res = self.thisptr.getNumPositionsPerVertex( nPositions )
        return res

    def getNumChannelsUVW(self):
        cdef dword nChannelsUVW = 0
        res = self.thisptr.getNumChannelsUVW( nChannelsUVW )
        return res

    #byte    setBaseAndPivot( Cbase base, Cbase pivot, real substepTime)
    def setBaseAndPivot(self, Base base, Base pivot, real substepTime=0.0):
        self.thisptr.setBaseAndPivot(deref(base.thisptr),deref(pivot.thisptr),substepTime)

    #byte    getBaseAndPivot( Cbase& base, Cbase& pivot, const_real substepTime)
    def getBaseAndPivot(self):
        cdef Cbase *base = <Cbase*>malloc(sizeof(Cbase))
        cdef Cbase *pivot = <Cbase*>malloc(sizeof(Cbase))
        cdef real substepTime = 0
        self.thisptr.getBaseAndPivot(deref(base),deref(pivot),substepTime)
        return _t_Base(base), _t_Base(pivot)



'''
# Method:    isRFRK. Returns isRfrk = 1 if this Cobject is a RealFlow particles object, otherwise returns 0.
byte isRFRK( byte& isRfrk )

# Method:    getRFRKParameters
byte getRFRKParameters( char*& binSeqNames, char*& rwName, char*& substractiveField,\
    real& scale, real& resolution, real& polySize, real& radius, real& smooth, real& core,\
    real& splash, real& maxVelocity, int& axis, real& fps, int& frame, int& offset, bool& f,\
    int& rwTesselation, bool& mb, real& mbCoef )


byte setRFRKParameters( const_char* binSeqNames, const_char* rwName, char* substractiveField,\
    real scale, real resolution, real polySize, real radius, real smooth, real core,\
                                                                               real splash, real maxVelocity, int axis, real fps, int frame, int offset, bool flipNorm,\
                                                                                                                                                              int rwTesselation, bool mb, real mbCoef )


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
byte    getProperties( byte& doDirectCausticsReflection, byte& doDirectCausticsRefraction,\
    byte& doIndirectCausticsReflection, byte& doIndirectCausticsRefraction )
byte    setProperties( byte doDirectCausticsReflection, byte doDirectCausticsRefraction,\
                                                             byte doIndirectCausticsReflection, byte doIndirectCausticsRefraction )

byte  getDependencies( dword& numDependencies, char** & paths, const_bool& searchInsideProxy )



byte    addChannelUVW( dword& index, byte id)
byte    generateSphericalUVW( dword& iChannel, Cbase& projectorBase,\
    real& startLatitude, real& endLatitude,\
    real& startLongitude, real& endLongitude )
byte    generateCylindricalUVW( dword& iChannel, Cbase& projectorBase,\
    real& startAngle, real& endAngle )
byte    generateCubicUVW( dword& iChannel, Cbase& projectorBase, bool mirrorBackFaces)
byte    generatePlanarUVW( dword& iChannel, Cbase& projectorBase )


byte    getVertex( dword iVertex, dword iPosition, Cpoint& point )
byte    setVertex( dword iVertex, dword iPosition, const_Cpoint& point )

byte    getNormal( dword iNormal, dword iPosition, Cvector& normal )
byte    setNormal( dword iNormal, dword iPosition, const_Cvector& normal )

byte    getTriangle( dword iTriangle, dword& iVertex1, dword& iVertex2, dword& iVertex3,\
                           dword& iNormal1, dword& iNormal2, dword& iNormal3 )
byte    setTriangle( dword iTriangle, dword iVertex1, dword iVertex2, dword iVertex3,\
                                                                            dword iNormal1, dword iNormal2, dword iNormal3 )

byte    getTriangleGroup( dword iTriangle, dword& idGroup )
byte    setTriangleGroup( dword iTriangle, dword idGroup )

byte    getTriangleUVW( dword iTriangle, dword iChannelID, float& u1, float& v1, float& w1,\
                                               float& u2, float& v2, float& w2, float& u3, float& v3, float& w3 )
byte    setTriangleUVW( dword iTriangle, dword iChannelID, float u1, float v1, float w1,\
                                                                                     float u2, float v2, float w2, float u3, float v3, float w3 )

byte    getTriangleMaterial( dword iTriangle, Cmaterial& material )
byte    setTriangleMaterial( dword iTriangle, Cmaterial material )

byte    getGroupMaterial( dword iGroup, Cmaterial& material )
byte    setGroupMaterial( dword iGroup, Cmaterial material )



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

byte    getUVWChannelProperties( dword iChannel, byte& projType, bool& customProj,\
                                       Cbase& projectorBase,\
                                       real& startLatitude, real& endLatitude,\
                                       real& startLongitude, real& endLongitude,\
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
byte getGeometryModifierExtensionParamsAtIndex( MXparamList*& extensionParams, dword modifierExtensionsIndex )'''

cdef object _t_Object_from_pointer(Cmaxwell* m,void *p):
    res = Object()
    res.setPointer(m,p)
    return res

cdef class Material:
    cdef Cmaxwell.Cmaterial thisptr

    def __cinit__(self):
        pass

    def __dealloc__(self):
        pass

    def setName(self, name):
        cdef const_char *c_string = name
        self.thisptr.setName(c_string)

    def getName(self):
        return self.thisptr.getName().decode('UTF-8')

cdef object _t_Material(Cmaxwell.Cmaterial p):
    res = Material()
    res.thisptr = p.createCopy()
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

    def setStep(self,dword iStep, point origin, point focalPoint, Vector up, focalLength, fStop, stepTime, focalLengthNeedCorrection = True):
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

    def getValues(self):
        ''' returns a dict with values '''
        cdef dword nSteps = 0
        cdef real shutter = 0
        cdef real orthoX = 0
        cdef real orthoY = 0
        cdef real orthoZoom = 0
        cdef real focalLenght = 0
        cdef real fStop = 0
        cdef const_char * pDiaphragmType
        cdef real angle = 0
        cdef dword nBlades = 0
        cdef real filmWidth = 0
        cdef real filmHeight = 0
        cdef real iso = 0
        cdef dword fps = 0
        cdef dword xRes = 0
        cdef dword yRes = 0
        cdef real pixelAspect = 0
        cdef byte projectionType = 0
        self.thisptr.getValues( nSteps, shutter, filmWidth, filmHeight, iso, &pDiaphragmType, angle, nBlades,\
            fps, xRes, yRes, pixelAspect,projectionType )
        return {'nSteps': nSteps, 'shutter': shutter, 'orthoX': orthoX,'orthoY': orthoY,'orthoZoom': orthoZoom,
                'focalLenght': focalLenght, 'fStop': fStop, 'pDiaphragmType': pDiaphragmType, 'angle': angle,'nBlades': nBlades,
                'filmWidth': filmWidth, 'filmHeight': filmHeight, 'iso': iso, 'fps': fps, 'xRes': xRes, 'yRes':yRes, 'pixelAspect': pixelAspect, 'projectionType': projectionType }

    def getOrthoValues(self, dword iStep):
        ''' returns a dict with values '''
        cdef real orthoX = 0
        cdef real orthoY = 0
        cdef real orthoZoom = 0
        cdef real focalLength = 0
        cdef real fStop = 0
        self.thisptr.getOrthoValues( iStep, orthoX, orthoY, orthoZoom, focalLength, fStop )
        return {'orthoX': orthoX,'orthoY': orthoY,'orthoZoom': orthoZoom, 'focalLenght': focalLength, 'fStop': fStop }

    #byte setResolution( dword xRes, dword yRes )
    def setResolution(self,dword xRes, dword yRes):
        self.thisptr.setResolution(xRes,yRes)

    #byte getResolution( dword& xRes, dword& yRes )
    def getResolution(self):
        cdef dword xRes = 0
        cdef dword yRes = 0
        self.thisptr.getResolution(xRes, yRes)
        return xRes, yRes

    #byte setPixelAspect( real pixelAspect )
    def setPixelAspect(self, real pixelAspect):
        self.thisptr.setPixelAspect(pixelAspect)

    #byte getPixelAspect( real& pixelAspect )
    def getPixelAspect(self):
        cdef real pixelAspect = 0
        self.thisptr.getPixelAspect(pixelAspect)
        return pixelAspect

    #byte    setActive()
    def setActive(self):
        self.thisptr.setActive()

    #byte setShutter( real shutter )
    def setShutter(self, real shutter):
        self.thisptr.setShutter(shutter)

    #byte getShutter( real& shutter )
    def getShutter(self):
        cdef real shutter = 0
        self.thisptr.getShutter(shutter)
        return shutter

    #byte setIso( real iso )
    def setIso(self, real iso):
        self.thisptr.setIso(iso)

    #byte getIso( real& iso )
    def getIso(self):
        cdef real iso = 0
        self.thisptr.getIso(iso)
        return iso

    #byte setFilmSize( real filmWidth, real filmHeight )
    def setFilmSize(self, real filmWidth, real filmHeight):
        self.thisptr.setFilmSize(filmWidth,filmHeight)

    #byte getFilmSize( real& filmWidth, real& filmHeight )
    def getFilmSize(self):
        cdef real filmWidth = 0
        cdef real filmHeight = 0
        self.thisptr.getFilmSize(filmWidth,filmHeight)
        return filmWidth, filmHeight

    #byte setDiaphragm( const_char* pDiaphragmType, real angle, dword nBlades )
    def setDiaphragm(self, const_char* pDiaphragmType, real angle, dword nBlades):
        self.thisptr.setDiaphragm(pDiaphragmType,angle, nBlades)

    #byte getDiaphragm( const_char** pDiaphragmType, real& angle, dword& nBlades )
    def getDiaphragm(self):
        cdef const_char* pDiaphragmType
        cdef real angle = 0
        cdef dword nBlades = 0
        self.thisptr.getDiaphragm(&pDiaphragmType,angle,nBlades)
        return {'pDiaphragmType': pDiaphragmType, 'angle': angle,'nBlades': nBlades}

    #byte setFPS( real fps )
    def setFPS(self, real fps):
        self.thisptr.setFPS(fps)

    #byte getFPS( real& fps )
    def getFPS(self):
        cdef real fps = 0
        self.thisptr.getFPS(fps)
        return fps

    #byte setScreenRegion( dword x1, dword y1, dword x2, dword y2, const_char* pRegionType )
    def setScreenRegion(self, dword x1, dword y1, dword x2, dword y2, const_char * pRegionType):
        self.thisptr.setScreenRegion(x1,y1,x2,y2,pRegionType)

    #byte getScreenRegion( dword& x1, dword& y1, dword& x2, dword& y2, char* pType )
    def getScreenRegion(self):
        cdef char * pType = <char *>malloc(sizeof(char[128]))
        cdef dword x1 = 0
        cdef dword y1 = 0
        cdef dword x2 = 0
        cdef dword y2 = 0
        self.thisptr.getScreenRegion(x1,y1,x2,y2,pType)
        res =  {'x1': x1, 'x2': x2, 'y1': y1,'y2': y2, 'pType': pType}
        free(pType)
        return res

    #byte setCutPlanes( real zNear, real zFar, bool enabled )
    def setCutPlanes(self, real zNear, real zFar, bool enabled):
        self.thisptr.setCutPlanes(zNear, zFar, enabled)

    #byte getCutPlanes( real& zNear, real& zFar, bool& enabled )
    def getCutPlanes(self):
        """
        Method:      getCutPlanes() -> (zNear,zFar,enabled)
        Description: Get cut planes of the camera ( 0.0 - 1e7 ) Default = 0.0
        """
        cdef real zNear = 0
        cdef real zFar = 0
        cdef bool enabled = 0
        self.thisptr.getCutPlanes(zNear,zFar,enabled)
        return zNear, zFar, enabled


    # Method:    get/setCustomBokeh.^M
    # Description: Defines a custom bokeh^M
    # Parameters: ^M
    #              ratio: aspect ratio (default: 1)^M
    #              angle: angle in radians^M
    #              enabled: sets the custom bokeh on/off^M
    #byte    setCustomBokeh( const_real& ratio, const_real& angle, bool enabled )
    def setCustomBokeh(self, real ratio, real angle, bool enabled):
        self.thisptr.setCustomBokeh(ratio,angle,enabled)

    #byte    getCustomBokeh( real& ratio, real& angle, bool& enabled )
    def getCustomBokeh(self):
        cdef real ratio = 0
        cdef real angle = 0
        cdef bool enabled = 0
        self.thisptr.getCustomBokeh(ratio,angle,enabled)
        return ratio, angle, enabled

        # Method:    set/getHide. sets/gets the hidden status of this camera (used only in Maxwell Studio)^M
        #byte    setHide( bool hide )
        #byte    isHide( bool& hide )

        # Method:    get/setUuid. Uuid that can be used for custom purposes^M
        #byte    setUuid( const_char* pUuid )
        #const_char* getUuid( )

        # Method:    get/setUserData  (Not used in plugins)^M
        #byte    setUserData( void* pData )
        #byte    getUserData( void** pData )