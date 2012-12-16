from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(
      name = "Maxwell",
      cmdclass = {"build_ext": build_ext},
      ext_modules = [Extension(
    "maxwell",                 # name of extension
    ["Cmaxwell.pyx"],           # filename of our Pyrex/Cython source
    language="c++",              # this causes Pyrex/Cython to create C++ source
    include_dirs=["h"],          # usual stuff
    libraries=["maxwellsdk"],             # ditto
    extra_compile_args=['-D_LINUX'],
    extra_link_args=['-Llib']
    )]
    )
