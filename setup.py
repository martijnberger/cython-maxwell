# -*- coding: utf-8 -*-

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import platform

extra = True

if platform.system() == 'Linux':
    libraries = ["maxwellsdk"]
    extra_compile_args=['-D_LINUX']
    extra_link_args=['-Llib']
elif platform.system() == 'Darwin': # OS x
    libraries=["mxs"]
    extra_compile_args=['-D_MACOSX','-D_LINUX','-DCOMPILER_GCC']
    extra_link_args=['-Llib/','-framework CoreGraphics']
else:
    libraries=["maxwell_plugins"]
    extra_compile_args=['/Zp8']
    extra_link_args=['/LIBPATH:Lib']
    extra = False

if extra:
    extra_compile_args.append('-g')
    extra_compile_args.append('-ggdb')
    extra_link_args.append('-g')
    extra_link_args.append('-ggdb')

setup(
      name = "Maxwell",
      cmdclass = {"build_ext": build_ext},
      ext_modules = [Extension(
    "maxwell",                 # name of extension
    ["maxwell.pyx"],           # filename of our Pyrex/Cython source
    language="c++",              # this causes Pyrex/Cython to create C++ source
    include_dirs=["h"],          # usual stuff
    libraries=libraries,             # ditto
    extra_compile_args=extra_compile_args,
    extra_link_args=extra_link_args,
    embedsignature=True
    )]
    )
