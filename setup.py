# -*- coding: utf-8 -*-

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import platform

if platform.system() == 'Linux':
    libraries = ["maxwellsdk"]
    extra_compile_args=['-D_LINUX']
    extra_link_args=['-Llib']
elif platform.system() == 'Darwin': # OS x
    libraries=["mxs"]
    extra_compile_args=['-D_MACOSX','-D_LINUX','-DCOMPILER_GCC']
    extra_link_args=['-Llib/','-framework CoreGraphics']
else:
    libraries=["maxwellsdk"]
    extra_compile_args=['-D_LINUX']
    extra_link_args=['-Llib']


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
    extra_link_args=extra_link_args
    )]
    )
