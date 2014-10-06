cimport fontstash as fs

cdef class Context:
    cdef fs.FONScontext * ctx
    cdef dict fonts
    cdef draw_text(self,float x,float y ,bytes text)