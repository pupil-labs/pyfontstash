import os, platform
from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

if platform.system() == 'Darwin':
	includes = ['/System/Library/Frameworks/OpenGL.framework/Versions/Current/Headers/']
	f = '-framework'
	link_args = [f, 'OpenGL']
	libs = []
else:
    includes = ['/usr/include/GL',]
    libs = ['GL']
    link_args = []


extensions = [
	#first submodule: utils
	Extension(	name="pyfontstash",
				sources=['pyfontstash.pyx'],
				include_dirs = includes,
				libraries = libs,
				extra_link_args=link_args,
				extra_compile_args=['-D FONTSTASH_IMPLEMENTATION','-D GLFONTSTASH_IMPLEMENTATION'])
]

#this package will be compiled into a single.so file.
setup( 	name="pyfontstash",
		version="0.0.1",
		author= 'Moritz Kassner',
		license = 'MIT',
		description="OpenGL GL font rendering. This module can also be used as a submodule for other cython projects that want to use OpenGL.",
		ext_modules=cythonize(extensions)
)