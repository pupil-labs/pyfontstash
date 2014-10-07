cimport fontstash as fs


cdef int FONS_ALIGN_LEFT
cdef int FONS_ALIGN_CENTER
cdef int FONS_ALIGN_RIGHT
cdef int FONS_ALIGN_TOP
cdef int FONS_ALIGN_MIDDLE
cdef int FONS_ALIGN_BOTTOM
cdef int FONS_ALIGN_BASELINE
cdef int FONS_ZERO_TOPLEFT
cdef int FONS_ZERO_BOTTOMLEFT


cdef class Context:
    cdef fs.FONScontext * ctx
    cdef dict fonts
    cpdef draw_text(self,float x,float y ,bytes text)
    cpdef set_color_float(self,float r, float g, float b, float a)