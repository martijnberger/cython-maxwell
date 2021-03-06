# -*- coding: utf-8 -*-

from cython.operator cimport dereference as deref, preincrement as inc
from libc.stdlib cimport malloc, free
from maxwell cimport Cmaxwell, byte

cdef byte mwcallback(byte isError, const char *pMethod, const char *pError, const void *pValue):
    if isError != 3: # 3 == INFO ???
        raise Exception("{} {} {}".format(isError, <char*>pMethod,<char*>pError))
    #print("{} {} {}".format(isError, str(pMethod), str(pError), deref(err_val)))

cdef class maxwell:
    cdef Cmaxwell *thisptr

    def __cinit__(self):
        self.thisptr = new Cmaxwell(&mwcallback)

    def __dealloc__(self):
        del self.thisptr

    def readMXS(self, filename):
        py_byte_string = filename.encode('UTF-8')
        cdef const char* f = py_byte_string
        res = self.thisptr.readMXS(f, READ_ALL)
        if res == 0:
            raise Exception("Could not open: {}".format(filename))

    def writeMXS(self, filename):
        py_byte_string = filename.encode('UTF-8')
        cdef const char* f = py_byte_string
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

    def getObject(self, name):
        #Cmaxwell.Cobject  getObject( const char* pObjectName )
        py_byte_string = name.encode('UTF-8')
        cdef const char* n = py_byte_string
        cdef Cmaxwell.Cobject o = self.thisptr.getObject(n)
        #print(<size_t> &o)
        #print(o.isNull())
        if o.isNull() is False:
            return _t_Object_from_pointer(self.thisptr, <Cmaxwell.Cobject* >o.getPointer())
        else:
            return False

    def getMaterial(self, name):
        #Cmaxwell.Cmaterial getMaterial( const char* pMaterialName )
        py_byte_string = name.encode('UTF-8')
        cdef const char* n = py_byte_string
        cdef Cmaxwell.Cmaterial m = self.thisptr.getMaterial(n)
        #print("Get Material {}".format(name))
        if m.isNull() is not <byte>1:
            return _t_Material(&m)
        else:
            return False

    def readMaterial(self, fileName ):
        '''
            readMaterial. Reads a material from disk. fileName = material path
        '''
        py_byte_string = fileName.encode('UTF-8')
        cdef const char* f = py_byte_string
        cdef Cmaxwell.Cmaterial m = self.thisptr.readMaterial(f)
        if m.isNull() is not <byte>1:
            return _t_Material(&m)
        else:
            raise Exception("Could not read material: {}".format(fileName))


    def addMaterial(self, Material mat):
        #Cmaxwell.Cmaterial addMaterial( Cmaxwell.Cmaterial& material )
        if mat.thisptr.isNull() != 0:
            raise Exception("Can not add NULL material")
        cdef Cmaxwell.Cmaterial m = self.thisptr.addMaterial(mat.thisptr)
        if m.isNull():
            raise Exception("Could not add material")
        return _t_Material(&m)

    def addObject(self, Object o):
        #Cmaxwell.Cobject     addObject( Cmaxwell.Cobject& object )
        if o.isNull():
            print("Cannot add non object")
            return
        cdef Cmaxwell.Cobject obj = self.thisptr.addObject(deref(o.thisptr))
        if obj.isNull() is not False:
            raise Exception("Could not add material")
        else:
            print("Object added {}".format(o.getName()))
            return _t_Object_from_pointer(self.thisptr, <Cmaxwell.Cobject *>obj.getPointer())


    def addCamera(self, name, dword nSteps, real shutter, real filmWidth, real filmHeight, real iso, DiaphragmType, real angle, dword nBlades, dword fps, dword xRes, dword yRes, real pixelAspect, byte projectionType=0):
    #Cmaxwell.Ccamera addCamera( const char* pName, dword nSteps, real shutter, real filmWidth,
    #real filmHeight, real iso, const char* pDiaphragmType, real angle,
    #dword nBlades, dword fps, dword xRes, dword yRes, real pixelAspect,
    #byte projectionType = 0)
        py_byte_string = name.encode('UTF-8')
        cdef const char* pName = py_byte_string
        py_byte_string2 = DiaphragmType.encode('UTF-8')
        cdef const char* pDiaphragmType = py_byte_string2
        cdef Cmaxwell.Ccamera obj = self.thisptr.addCamera(pName, nSteps, shutter, filmWidth, filmHeight, iso, pDiaphragmType, angle, nBlades,  fps,  xRes,  yRes,  pixelAspect, TYPE_THIN_LENS )
        return _t_Camera(obj)




    def createInstancement(self, name, Object o):
        #Cmaxwell.Cobject     createInstancement( const char* pName, Cmaxwell.Cobject& object )
        py_byte_string = name.encode('UTF-8')
        cdef const char* n = py_byte_string
        cdef Cmaxwell.Cobject obj = self.thisptr.createInstancement(n, deref(o.thisptr))
        #if obj.isNull() is not <byte>1:
        #    raise Exception("Could not createInstancement {}".format(name))
        return _t_Object_from_pointer(self.thisptr, <Cmaxwell.Cobject *>obj.getPointer())

    def createMesh(self, name, dword nVertexes, dword nNormals, dword nTriangles, dword nPositionsPerVertex ):
    #Cmaxwell.Cobject createMesh( const char* pName, dword nVertexes, dword nNormals, dword nTriangles, dword nPositionsPerVertex )
        py_byte_string = name.encode('UTF-8')
        cdef const char* pName = py_byte_string
        cdef Cmaxwell.Cobject obj = self.thisptr.createMesh( pName, nVertexes, nNormals, nTriangles, nPositionsPerVertex )
        return _t_Object_from_pointer(self.thisptr, <Cmaxwell.Cobject *>obj.getPointer())



            #broken need a way to get the actual object pointer
    def getMaterialsIterator(self):
        #    #return ObjectIterator(self)
        cdef Cmaxwell.Cmaterial.Citerator it
        cdef Cmaxwell.Cmaterial m = it.first(self.thisptr)
        while m.isNull() == <byte>0:
            yield _t_Material_(m)
            m = it.next()

    def getCamerasIterator(self):
        #    #return ObjectIterator(self)
        cdef Cmaxwell.Ccamera.Citerator it
        cdef Cmaxwell.Ccamera m = it.first(self.thisptr)
        while m.isNull() == <byte>0:
            yield _t_Camera(m)
            m = it.next()

    def freeScene(self):
        self.thisptr.freeScene()




    def setRenderParameter(self, ParameterName, ParameterValue ):
        py_byte_string = ParameterName.encode('UTF-8')
        cdef char* pParameterName = py_byte_string
        s, t = getSizeFromRenderParameter(pParameterName)
        cdef dword size = s
        cdef byte f_res = 0
        cdef byte byte_res
        cdef float float_res
        cdef real real_res
        cdef char* char_res
        cdef dword dword_res
        if t is 'BYTE':
            byte_res = ParameterValue
            f_res = pParameterValue = self.thisptr.setRenderParameter(pParameterName, size, &byte_res )
        elif t is 'FLOAT':
            float_res = ParameterValue
            f_res = pParameterValue = self.thisptr.setRenderParameter(pParameterName, size, &float_res )
        elif t is 'REAL':
            real_res = ParameterValue
            f_res = pParameterValue = self.thisptr.setRenderParameter(pParameterName, size, &real_res )
        elif t is 'DWORD':
            dword_res = ParameterValue
            f_res = pParameterValue = self.thisptr.setRenderParameter(pParameterName, size, &dword_res )
        else: # is most likely a char * # pParameterName in [b"ENGINE"]:
            py_byte_string = ParameterValue.encode('UTF-8')
            char_res = py_byte_string
            f_res = pParameterValue = self.thisptr.setRenderParameter(pParameterName, size, char_res )
        if f_res == 0:
            raise Exception("setRenderParameter failed")

    def getRenderParameter(self,  ParameterName ):
        py_byte_string = ParameterName.encode('UTF-8')
        cdef char* pParameterName = py_byte_string
        s, t = getSizeFromRenderParameter(pParameterName)
        cdef dword size = s
        cdef void* pParameterValue
        pParameterValue = malloc(s)
        f_res = self.thisptr.getRenderParameter(pParameterName, size, pParameterValue)
        res = None
        if f_res != 1:
            raise Exception("getRenderParameter failed")
        elif t is 'BYTE':
            res = deref(<byte*>pParameterValue)
        elif t is 'FLOAT':
            res =  deref(<float*>pParameterValue)
        elif t is 'REAL':
            res = deref(<real*>pParameterValue)
        elif t is 'DWORD':
            res = deref(<dword*>pParameterValue)
        else:
            res =  <char*>pParameterValue
        free(pParameterValue)
        return  res

cdef getSizeFromRenderParameter(const char* RenderParameter):
    byte_vals = [b"DO SHARPNESS",b"DO DEVIGNETTING",b"REMOVE FILES AFTER COPY",b"DO MOTION BLUR",b"DO DISPLACEMENT",b"DO DISPERSION",b"DO DIFFUSE LAYER",
                 b"DO REFLECTION LAYER",b"DO DIRECT LAYER",b"DO INDIRECT LAYER",b"DO DIRECT REFLECTION CAUSTIC LAYER",b"DO INDIRECT REFLECTION CAUSTIC LAYER",
                 b"DO DIRECT REFRACTION CAUSTIC LAYER",b"DO INDIRECT REFRACTION CAUSTIC LAYER",b"DO RENDER CHANNEL",b"DO ALPHA CHANNEL",b"OPAQUE ALPHA",
                 b"EMBED CHANNELS",b"DO IDOBJECT CHANNEL",b"DO IDMATERIAL CHANNEL",b"DO SHADOW PASS CHANNEL",b"DO MOTION CHANNEL",b"DO ROUGHNESS CHANNEL",
                 b"DO FRESNEL CHANNEL",b"DO NORMALS CHANNEL",b"NORMALS CHANNEL SPACE",b"POSITION CHANNEL SPACE",b"MOTION CHANNEL TYPE",b"DO POSITION CHANNEL",
                 b"DO ZBUFFER CHANNEL",b"DO SCATTERING_LENS",b"DO NOT SAVE MXI FILE",b"DO NOT SAVE IMAGE FILE",b"RENAME AFTER SAVING",b"SAVE LIGHTS IN SEPARATE FILES",
                 b"USE MULTILIGHT"]
    if RenderParameter in byte_vals:
        return (sizeof( byte ), 'BYTE')
    if RenderParameter in [b"SAMPLING LEVEL"]:
        return (sizeof( float ), 'FLOAT')
    if RenderParameter in [b"ENGINE"]:
        return (3 * sizeof( char ), 'CHAR')
    if RenderParameter in [b"ZBUFFER RANGE",b"DEVIGNETTING",b"SCATTERING_LENS",b"SHARPNESS"]:
        return (sizeof( real ), 'REAL')
    if RenderParameter in [b"NUM THREADS", b"STOP TIME"]:
        return (sizeof( dword ), 'DWORD')
    else: # is most likely a char *
        return (sizeof( char ) * 256, 'CHAR')

'''
cdef class point:
    cdef Cmaxwell.Cpoint *thisptr
    cdef bool cleanup

    def __cinit__(self, bool __cleanup=True, __init=True):
        if __init:
            self.thisptr = new Cmaxwell.Cpoint()
        self.cleanup = __cleanup

    def __init__(self, __cleanup=True, __init=True):
        self.thisptr = new Cvector()

    def __dealloc__(self):
        if self.cleanup:
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
'''

cdef class Vector:
    cdef Cvector *thisptr
    cdef bool cleanup

    def __cinit__(self, x=0, y=0, z=0, bool __cleanup=True):
        self.thisptr = new Cvector(x,y,z)
        self.cleanup = __cleanup

    def __init__(self, x=0, y=0, z=0, __cleanup=True):
        self.x = x
        self.y = y
        self.z = z

    def __dealloc__(self):
        if self.cleanup:
            del self.thisptr

    def __str__(self):
        return "vector: [{} {} {}]".format(self.x,self.y, self.z )

    __unicode__ = __str__

    __repr__ = __str__

    def scale(self, double scale):
        self.thisptr.x *= scale
        self.thisptr.y *= scale
        self.thisptr.z *= scale


    def set(self, double x, double y, double z):
        self.thisptr.x = x
        self.thisptr.y = y
        self.thisptr.z = z

    def __getitem__(self,int n):
        if n == 0:
            return self.x
        elif n == 1:
            return self.y
        elif n == 2:
            return self.z
        else:
            raise Exception("Access vector out of range")

    def __setitem__(self,int n, double i):
        if n == 0:
            self.x = i
        elif n == 1:
            self.y = i
        elif n ==2:
            self.z = i
        else:
            raise Exception("Access vector out of range")

    def __len__(self):
        return 3

    property x:
        def __get__(self): return self.thisptr.x
        def __set__(self, double x): self.thisptr.x = x

    property y:
        def __get__(self): return self.thisptr.y
        def __set__(self, double y): self.thisptr.y = y

    property z:
        def __get__(self): return self.thisptr.z
        def __set__(self, double z): self.thisptr.z = z


cdef object _t_Vector(Cvector *p, bool cleanup=True):
    res = Vector(__cleanup=cleanup)
    del res.thisptr
    res.thisptr = p
    return res


cdef class Base:
    '''
        Wrapper for CBase
    '''
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
        self.origin = origin
        self.x = x
        self.y = y
        self.z = z
        return self

    def __str__(self):
        return "origin : {} {} {}".format(self.origin.x,self.origin.y,self.origin.z) + \
               "\n     x : {} {} {}".format(self.x.x,self.x.y,self.x.z) + \
               "\n     y : {} {} {}".format(self.y.x,self.y.y,self.y.z) + \
               "\n     z : {} {} {}".format(self.z.x,self.z.y,self.z.z)

    __repr__ = __str__
    
    property origin:
        def __get__(self): return _t_Vector(&self.thisptr.origin,False)
        def __set__(self, Vector origin):
            self.thisptr.origin.x = origin.x
            self.thisptr.origin.y = origin.y
            self.thisptr.origin.z = origin.z

    property x:
        def __get__(self): return _t_Vector(&self.thisptr.xAxis,False)
        def __set__(self, Vector x):
            self.thisptr.xAxis.x = x.x
            self.thisptr.xAxis.y = x.y
            self.thisptr.xAxis.z = x.z

    property y:
        def __get__(self): return _t_Vector(&self.thisptr.yAxis,False)
        def __set__(self, Vector y):
            self.thisptr.yAxis.x = y.x
            self.thisptr.yAxis.y = y.y
            self.thisptr.yAxis.z = y.z

    property z:
        def __get__(self): return _t_Vector(&self.thisptr.zAxis,False)
        def __set__(self, Vector z): self.thisptr.zAxis = deref(z.thisptr)


cdef object _t_Base(Cbase *p):
    res = Base(__skip_creation=True)
    res.thisptr = p
    return res


cdef class Object:
    cdef Cmaxwell.Cobject *thisptr
    cdef Cmaxwell *sceneptr
    cdef bool skip_dealloc

    def __cinit__(self):
        self.skip_dealloc =0
        self.thisptr = NULL

    def __dealloc__(self):
        if self.skip_dealloc == 0 and self.thisptr is not NULL:
            del self.thisptr
            self.thisptr = NULL


    def free(self):
        #print("attemting to free {}".format(self.getName()))
        self.thisptr.free()
        self.thisptr = NULL

    cdef setPointer(self,Cmaxwell * m, void* p):
        self.thisptr = new Cmaxwell.Cobject()
        self.sceneptr = m
        self.thisptr.setPointer(m,p)

    def setName(self, name):
        cdef const char *c_string = name
        self.thisptr.setName(c_string)

    def getName(self):
        cdef char* name
        self.thisptr.getName(&name)
        res = name.decode('UTF-8','replace')
        return res

    def isMesh(self):
        cdef byte res = 0
        self.thisptr.isMesh(res)
        return True if res == 1 else False

    def isInstance(self):
        cdef byte res = 0
        self.thisptr.isInstance(res)
        return True if res == 1 else False

    def getInstanced(self):
        cdef Cmaxwell.Cobject res = self.thisptr.getInstanced()
        return _t_Object_from_pointer(self.sceneptr,  res.getPointer())

    def isNull(self):
        return True if self.thisptr.isNull() == 1 else False

    # Method:    get/setProxyPath. Get/sets the scene file referenced by this object
    def getReferencedScenePath(self):
        return self.thisptr.getReferencedScenePath().decode('UTF-8')

    def setReferencedScenePath(self, const char* proxyPath):
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
        self.thisptr.getVerticesCount(nVertexes)
        return nVertexes

    def getNumTriangles(self):
        cdef dword nTriangles = 0
        res = self.thisptr.getTrianglesCount( nTriangles )
        return nTriangles

    def getNumNormals(self):
        cdef dword nNormals = 0
        res = self.thisptr.getNormalsCount( nNormals )
        return nNormals

    def getNumPositionsPerVertex(self):
        cdef dword nPositions = 0
        res = self.thisptr.getPositionsPerVertexCount( nPositions )
        return nPositions

    def getNumChannelsUVW(self):
        cdef dword nChannelsUVW = 0
        res = self.thisptr.getChannelsUVWCount( nChannelsUVW )
        return nChannelsUVW

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

    # Method:    get/setMaterial. Material applied to the object
    #byte    getMaterial( Cmaterial& material )
    def getMaterial(self):
        cdef Cmaxwell.Cmaterial* material = <Cmaxwell.Cmaterial*>malloc(sizeof(Cmaxwell.Cmaterial))
        self.thisptr.getMaterial(deref(material))
        return _t_Material(material)

    #byte    setMaterial( Cmaterial material )
    def setMaterial(self, Material m):
        self.thisptr.setMaterial(m.thisptr)

    #byte    getVertex( dword iVertex, dword iPosition, Cpoint& point )
    def getVertex(self, dword iVertex, dword iPosition):
        cdef Cpoint* p = <Cmaxwell.Cpoint *>malloc(sizeof(Cpoint))
        res = self.thisptr.getVertex(iVertex,iPosition, deref(p))
        if res == 0:
            raise IndexError('Vertex out of range')
        return _t_Vector(p)

    #byte    setVertex( dword iVertex, dword iPosition, const_Cpoint& point )
    def setVertex(self, dword iVertex, dword iPosition, Vector p):
        self.thisptr.setVertex(iVertex,iPosition,deref(p.thisptr))
        p.cleanup = False # make sure we dont free the Cpoint when we promised not to

    #byte    getNormal( dword iNormal, dword iPosition, Cvector& normal )
    def getNormal(self, dword iNormal, dword iPosition):
        cdef Cvector* v = <Cvector *>malloc(sizeof(Cvector))
        res = self.thisptr.getNormal(iNormal, iPosition, deref(v))
        if res == 0:
            raise IndexError('Normal out of range')
        return _t_Vector(v)

    #byte    setNormal( dword iNormal, dword iPosition, const_Cvector& normal )
    def setNormal(self, dword iNormal, dword iPosition, Vector v):
        self.thisptr.setNormal(iNormal,iPosition, deref(v.thisptr))
        v.cleanup = False

    #byte    getTriangle( dword iTriangle, dword& iVertex1, dword& iVertex2, dword& iVertex3,\
    #                           dword& iNormal1, dword& iNormal2, dword& iNormal3 )
    def getTriangle(self, dword iTriangle):
        cdef dword v1 = 0
        cdef dword v2 = 0
        cdef dword v3 = 0
        cdef dword n1 = 0
        cdef dword n2 = 0
        cdef dword n3 = 0
        res = self.thisptr.getTriangle(iTriangle, v1, v2, v3, n1, n2, n3)
        if res == 0:
            raise IndexError('Triangle out of range')
        return (v1,v2,v3,n1,n2,n3)


    #byte    setTriangle( dword iTriangle, dword iVertex1, dword iVertex2, dword iVertex3,\
    #                                      dword iNormal1, dword iNormal2, dword iNormal3 )
    def setTriangle(self,dword iTriangle, \
                         dword iVertex1, dword iVertex2, dword iVertex3, \
                         dword iNormal1,  dword iNormal2, dword iNormal3 ):
        cdef byte res = self.thisptr.setTriangle( iTriangle,  iVertex1,  iVertex2,  iVertex3,  iNormal1,  iNormal2,  iNormal3 )
        if res == 0:
            raise IndexError('Triangle out of range')

    #byte    getTriangleGroup( dword iTriangle )
    #def getTriangleGroup(self, dword iTriangle):
    #    cdef dword idGroup = 0
    #    cdef byte res = self.thisptr.getTriangleGroup( iTriangle, idGroup )
    #    if res == 0:
    #        raise IndexError('Triangle out of range')
    #    return idGroup

    #byte    setTriangleGroup( dword iTriangle, dword idGroup )
    #def setTriangleGroup(self, dword iTriangle, dword idGroup ):
    #    cdef byte res = self.thisptr.setTriangleGroup(iTriangle, idGroup)
    #    if res == 0:
    #        raise IndexError('Triangle out of range')


    #byte    getTriangleUVW( dword iTriangle, dword iChannelID, float& u1, float& v1, float& w1,\
    #                        float& u2, float& v2, float& w2, float& u3, float& v3, float& w3 )
    def getTriangleUVW(self,dword iTriangle, dword iChannelID):
        cdef float u1 = 0
        cdef float v1 = 0
        cdef float w1 = 0
        cdef float u2 = 0
        cdef float v2 = 0
        cdef float w2 = 0
        cdef float u3 = 0
        cdef float v3 = 0
        cdef float w3 = 0
        cdef byte res = self.thisptr.getTriangleUVW(iTriangle,iChannelID,u1, v1, w1, u2, v2, w2, u3, v3, w3)
        if res == 0:
            raise IndexError('Triangle out of range')
        return (u1, v1, w1, u2, v2, w2, u3, v3, w3)


    #byte    setTriangleUVW( dword iTriangle, dword iChannelID, float u1, float v1, float w1,\
    #                        float u2, float v2, float w2, float u3, float v3, float w3 )
    def setTriangleUVW(self, dword iTriangle, dword iChannelID, float u1, float v1, float w1, \
                             float u2, float v2, float w2, float u3, float v3, float w3 ):
        cdef byte res = self.thisptr.setTriangleUVW( iTriangle, iChannelID, u1, v1, w1,u2, v2, w2, u3, v3, w3 )
        if res == 0:
            raise IndexError('Triangle out of range')

    #byte    getTriangleMaterial( dword iTriangle, Cmaterial& material )\
    def getTriangleMaterial(self,dword iTriangle):
        cdef Cmaxwell.Cmaterial* mat = new Cmaxwell.Cmaterial()
        cdef byte res = self.thisptr.getTriangleMaterial(iTriangle,deref(mat))
        if res == 0:
            raise IndexError('Material out of range')
        return _t_Material(mat)


    #byte    setTriangleMaterial( dword iTriangle, Cmaterial material )
    def setTriangleMaterial(self, dword iTriangle, Material material ):
        cdef byte res = self.thisptr.setTriangleMaterial(iTriangle, material.thisptr)
        if res == 0:
            raise IndexError('setTriangleMaterial failed')


    #byte    getGroupMaterial( dword iGroup, Cmaterial& material )
    #def getGroupMaterial(self, dword iGroup):
    #    cdef Cmaxwell.Cmaterial* mat = new Cmaxwell.Cmaterial()
    #    cdef byte res = self.thisptr.getGroupMaterial(iGroup,deref(mat))
    #    if res == 0:
    #        raise IndexError('Material out of range')
    #    return _t_Material(mat)


    #byte    setGroupMaterial( dword iGroup, Cmaterial material )
    #def setGroupMaterial(self, iGroup, Material material ):
    #    cdef byte res = self.thisptr.setGroupMaterial(iGroup, material.thisptr)
    #    if res == 0:
    #        raise IndexError('setTriangleMaterial failed')

    #
    # DISPLAY FUNCTIONS. Getters/setters of visibility attributes of  Cobject
    #
    def getHide(self):
        #byte getHide( bool& hide )
        cdef bool hide = 0
        cdef byte res = self.thisptr.getHide(hide)
        if res == 0:
            raise TypeError('Cannot call getHide on this')
        return True if hide == 1 else False


    def setHide(self, bool hide):
        #byte setHide( bool hide )
        cdef byte res = self.thisptr.setHide(hide)
        if res == 0:
            raise TypeError('call setHide on this failed')

    def getHideToCamera(self):
        #byte getHideToCamera( bool& hide )
        cdef bool hide = 0
        cdef byte res = self.thisptr.getHideToCamera(hide)
        if res == 0:
            raise TypeError('Cannot call getHideToCamera on this')
        return True if hide == 1 else False

    def setHideToCamera(self, bool hide ):
        #byte setHideToCamera( bool hide )
        cdef byte res = self.thisptr.setHideToCamera(hide)
        if res == 0:
            raise TypeError('call setHideToCamera on this failed')

    #byte getHideToReflectionsRefractions( bool& hide )
    #byte setHideToReflectionsRefractions( bool hide )

    #byte getHideToGI( bool& hide )
    #byte setHideToGI( bool hide )

    #byte isExcludedOfCutPlanes( bool& excluded )
    #byte excludeOfCutPlanes( bool exclude )

    def isPosRotScaleInitialized(self):
        #byte    isPosRotScaleInitialized( bool& init )
        cdef bool init = 0
        cdef byte res = self.thisptr.isPosRotScaleInitialized(init)
        if res == 0:
            raise TypeError('cannot call isPosRotScaleInitialized() on this')
        return True if init == 1 else False


    def getPivotRotation(self):
        #byte    getPivotRotation( Cvector& vector )
        cdef Cvector v = Cvector()
        cdef byte res = self.thisptr.getPivotRotation(v)
        if res == 0:
            raise TypeError('cannot call getPivotRotation() on this')
        return _t_Vector(&v)

    def setPivotRotation(self, Vector v):
        #byte    setPivotRotation( Cvector vector )
        cdef byte res = self.thisptr.setPivotRotation(deref(v.thisptr))
        if res == 0:
            raise TypeError('cannot call setPivotRotation() on this')

    def getPivotPosition(self):
        #byte    getPivotPosition( Cvector& vector )
        resV = Vector()
        cdef byte res = self.thisptr.getPivotPosition(deref(resV.thisptr))



    def setPivotPosition(self, Vector v):
        #byte    setPivotPosition( Cvector vector )
        pass

    def getPosition(self):
        #byte    getPosition( Cvector& vector )
        pass

    def setPosition(self, Vector v):
        #byte    setPosition( Cvector vector )
        cdef byte res = self.thisptr.setPosition(deref(v.thisptr))

    def getRotation(self):
        #byte    getRotation( Cvector& vector )
        pass

    def setRotation(self, Vector v):
        #byte    setRotation( Cvector vector )
        cdef byte res = self.thisptr.setPosition(deref(v.thisptr))

        #byte    getScale( Cvector& vector )
        #byte    setScale( Cvector vector )

        #byte    getShear( Cvector& vector )
        #byte    setShear( Cvector vector )

'''

# Method:    get/setReferenceMaterial. Get/sets the material of an specific object inside the referenced scene
byte getReferencedSceneMaterial( const char* objectName, Cmaterial& material )
byte setReferencedSceneMaterial( const char* objectName, Cmaterial material )

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
const char* getUuid( )
byte    setUuid( const char* pUuid )



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


# Method:    cleanGeometry
# Description: Optional routine that removes degenerated triangles, repeated/unused vertex and normals.
# This function is automatically called inside the writeMXS method
# it is not needed to call it except in scenarios like the interactive engine
byte    cleanGeometry()



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

cdef object _t_Object_from_pointer(Cmaxwell* m,void *p, do_dealloc = 0):
    res = Object()
    res.skip_dealloc = 1
    res.setPointer(m,p)
    return res

cdef class Material:
    cdef Cmaxwell.Cmaterial thisptr
    cdef bool cleanup

    def __cinit__(self, __cleanup=True):
        self.cleanup = __cleanup

    def __dealloc__(self):
        #if self.cleanup == True:
        #    print("Cleanup Material: {}".format(<long> self.thisptr))
        #    del &self.thisptr
        pass

    property name:
        def __set__(self, name):
            cdef const char *c_string = name
            self.thisptr.setName(c_string)
        def __get__(self):
            return self.thisptr.getName().decode('UTF-8')

    def isNull(self):
        return True if self.thisptr.isNull() == 1 else False

    def getNumLayers(self):
        cdef byte nLayers = 0
        self.thisptr.getNumLayers(nLayers)
        return nLayers

    def getLayer(self, byte index):
        cdef Cmaxwell.CmaterialLayer l = self.thisptr.getLayer(index)
        return _t_MaterialLayer(l)

    def read(self, filename):
        py_byte_string = filename.encode('UTF-8')
        cdef const char* f = py_byte_string
        cdef byte r = self.thisptr.read(f)
        if r == <byte>0:
            raise IOError('Could not material read {}'.format(f))

    def write(self, filename):
        py_byte_string = filename.encode('UTF-8')
        cdef const char* f = py_byte_string
        cdef byte r = self.thisptr.write(f)
        if r == <byte>0:
            raise IOError('Could not material read {}'.format(f))


    property NormalMapState:
        def __get__(self):
            '''
                normal mapping for the global bump parameter
            '''
            cdef bool enabled = 0
            cdef byte res = self.thisptr.getNormalMapState(enabled)
            if res == 0:
                raise IOError('Could not read from material')
            return enabled

    property colorID:
        def __get__(self):
            cdef Crgb col
            cdef byte res = self.thisptr.getColorID(col)
            if res == 0:
                raise IOError('Could not read from material')
            return _t_rgb(&col)

    property dispersion:
        def __get__(self):
            cdef bool enabled = 0
            cdef byte res = self.thisptr.getDispersion(enabled)
            if res == 0:
                raise IOError('Could not read from material')
            return enabled

    property matte:
        def __get__(self):
            cdef bool enabled = 0
            cdef byte res = self.thisptr.getMatte(enabled)
            if res == 0:
                raise IOError('Could not read from material')
            return enabled


    property matteShadow:
        def __get__(self):
            cdef bool enabled = 0
            cdef byte res = self.thisptr.getMatteShadow(enabled)
            if res == 0:
                raise IOError('Could not read from material')
            return enabled

    def __repr__(self):
        return "Maxwell material:" + self.getName()


cdef object _t_Material(Cmaxwell.Cmaterial* p):
    res = Material(__cleanup=False)
    res.thisptr = deref(p)
    return res

cdef object _t_Material_(Cmaxwell.Cmaterial p):
    res = Material(__cleanup=True)
    cdef Cmaxwell.Cmaterial c = <Cmaxwell.Cmaterial>(p.createCopy())
    res.thisptr = c
    return res

cdef class MaterialLayer:
    cdef Cmaxwell.CmaterialLayer thisptr

    def getNumBSDFs(self):
        cdef byte nBSDFs = 0
        res =  self.thisptr.getNumBSDFs( nBSDFs )
        if res == 0:
            raise Exception("Cmaxwell error")
        return nBSDFs

    def getBSDF(self,byte index):
        #Cmaxwell.Cbsdf   getBSDF( byte index )
        res = self.thisptr.getBSDF(index)
        return _t_BSDF(res)

cdef object _t_MaterialLayer(Cmaxwell.CmaterialLayer l):
    res = MaterialLayer()
    res.thisptr = l
    return res

cdef class BSDF:
    cdef Cmaxwell.Cbsdf thisptr

    def getReflectance(self):
        res =  _t_Reflectance(self.thisptr.getReflectance())
        return res

cdef object _t_BSDF(Cmaxwell.Cbsdf b):
    if b.isNull() == 0:
        res = BSDF()
        res.thisptr = b
        return res

cdef class Reflectance:
    cdef Cmaxwell.Creflectance thisptr

    def getAttribute(self, str attribute):
        cdef Cmaxwell.Cattribute a
        cdef const char* res_string

        if attribute == 'color':
            self.thisptr.getAttribute('color', a)
            if a.activeType == MAP_TYPE_RGB:
                return (a.rgb.r, a.rgb.g, a.rgb.b)
            if a.activeType == MAP_TYPE_BITMAP:
                res_string = a.textureMap.getPath()
                return res_string
    #    self.thisptr.get
    #    a = bytes(channel, "UTF-8")
    #    cdef Cmaxwell.CmultiValue.Cmap* map = new Cmaxwell.CmultiValue.Cmap()
    #    cdef const char* pID = a
    #    res = self.thisptr.getColor(pID, deref(map))
    #    if res == 0:
    #        raise Exception("getColor failed")
    #    return _t_MultiValueMap(map)




cdef object _t_Reflectance(Cmaxwell.Creflectance r):
    res = Reflectance()
    res.thisptr = r
    return res

#cdef class MultiValueMap:
#    cdef Cmaxwell.CmultiValue.Cmap thisprt
#
#    property rgb:
#        def __get__(self): return _t_rgb(&self.thisprt.rgb)
#
#    property pFileName:
#        def __get__(self):
#            if self.thisprt.pFileName != NULL:
#                return self.thisprt.pFileName
#
#cdef object _t_MultiValueMap(Cmaxwell.CmultiValue.Cmap* m):
#   res = MultiValueMap()
#   res.thisprt = deref(m)
#   return res


cdef class rgb:
    cdef Crgb* thisptr

    property r:
        def __get__(self): return self.thisptr.r
        def __set__(self, r): self.thisptr.r = r

    property g:
        def __get__(self): return self.thisptr.g
        def __set__(self, g): self.thisptr.g = g

    property b:
        def __get__(self): return self.thisptr.b
        def __set__(self, b): self.thisptr.b = b


cdef object _t_rgb(Crgb* r):
    res = rgb()
    res.thisptr = r
    return res

'''    cdef cppclass Crgb(Cvector3DT[float]):
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
        bool constrain( )'''





cdef class camera:
    cdef Cmaxwell.Ccamera thisptr

    def __cinit__(self):
        pass

    def __dealloc__(self):
        pass

    def setName(self, name):
        cdef const char *c_string = name
        self.thisptr.setName(c_string)

    def getName(self):
        return self.thisptr.getName().decode('UTF-8')

    def setStep(self,dword iStep, Vector origin, Vector focalPoint, Vector up, focalLength, fStop, stepTime, focalLengthNeedCorrection = True):
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
        return [_t_Vector(o),_t_Vector(fP),_t_Vector(u),fL,fS,sT]

    #def setOrthoValues(self, dword iStep, real orthoX, real orthoY, real orthoZoom, real focalLength, real fStop ):
    #    self.thisptr.setOrthoValues( iStep,orthoX, orthoY, orthoZoom, focalLength, fStop )

    #def getOrthoValues(self, dword iStep):
    #    cdef real orthoX = 0
    #    cdef real orthoY = 0
    #    cdef real orthoZoom = 0
    #    cdef real focalLength = 0
    #    cdef real fStop = 0
    #    self.thisptr.getOrthoValues( iStep, orthoX, orthoY, orthoZoom, focalLength, fStop )
    #    return [orthoX,orthoY,orthoZoom,focalLength,fStop]

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
        cdef const char * pDiaphragmType
        cdef real angle = 0
        cdef dword nBlades = 0
        cdef real filmWidth = 0
        cdef real filmHeight = 0
        cdef real iso = 0
        cdef real fps = 0
        cdef dword xRes = 0
        cdef dword yRes = 0
        cdef real pixelAspect = 0
        cdef byte projectionType = 0
        #self.thisptr.getValues( nSteps, shutter, filmWidth, filmHeight, iso, ,\
        #    fps, xRes, yRes, pixelAspect,projectionType )
        self.thisptr.getShutter(shutter)
        self.thisptr.getFilmSize(filmWidth, filmHeight)
        self.thisptr.getIso(iso)
        self.thisptr.getDiaphragm(&pDiaphragmType, angle, nBlades)
        self.thisptr.getFPS(fps)
        self.thisptr.getResolution(xRes, yRes)
        self.thisptr.getPixelAspect(pixelAspect)
        return {'nSteps': nSteps, 'shutter': shutter, 'orthoX': orthoX,'orthoY': orthoY,'orthoZoom': orthoZoom,
                'focalLenght': focalLenght, 'fStop': fStop, 'pDiaphragmType': pDiaphragmType, 'angle': angle,'nBlades': nBlades,
                'filmWidth': filmWidth, 'filmHeight': filmHeight, 'iso': iso, 'fps': fps, 'xRes': xRes, 'yRes':yRes, 'pixelAspect': pixelAspect, 'projectionType': projectionType }

    #def getOrthoValues(self, dword iStep):
    #    ''' returns a dict with values '''
    #    cdef real orthoX = 0
    #    cdef real orthoY = 0
    #    cdef real orthoZoom = 0
    #    cdef real focalLength = 0
    #    cdef real fStop = 0
    #    self.thisptr.getOrthoValues( iStep, orthoX, orthoY, orthoZoom, focalLength, fStop )
    #    return {'orthoX': orthoX,'orthoY': orthoY,'orthoZoom': orthoZoom, 'focalLenght': focalLength, 'fStop': fStop }

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

    #byte setDiaphragm( const char* pDiaphragmType, real angle, dword nBlades )
    def setDiaphragm(self, const char* pDiaphragmType, real angle, dword nBlades):
        self.thisptr.setDiaphragm(pDiaphragmType,angle, nBlades)

    #byte getDiaphragm( const char** pDiaphragmType, real& angle, dword& nBlades )
    def getDiaphragm(self):
        cdef const char* pDiaphragmType
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

    #byte setScreenRegion( dword x1, dword y1, dword x2, dword y2, const char* pRegionType )
    def setScreenRegion(self, dword x1, dword y1, dword x2, dword y2, const char * pRegionType):
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
        #byte    setUuid( const char* pUuid )
        #const char* getUuid( )

        # Method:    get/setUserData  (Not used in plugins)^M
        #byte    setUserData( void* pData )
        #byte    getUserData( void** pData )

cdef _t_Camera(Cmaxwell.Ccamera c):
    res = camera()
    res.thisptr = c
    return res
