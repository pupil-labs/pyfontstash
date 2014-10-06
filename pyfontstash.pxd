cimport fontstash as fs

cdef class Context:
    cdef fs.FONScontext * ctx
    cdef dict fonts
    cpdef draw_text(self,float x,float y ,bytes text)