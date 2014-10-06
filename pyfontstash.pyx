cimport fontstash as fs


#expose some constansts

FONS_ALIGN_LEFT = fs.FONS_ALIGN_LEFT
FONS_ALIGN_CENTER = fs.FONS_ALIGN_CENTER
FONS_ALIGN_RIGHT = fs.FONS_ALIGN_RIGHT
FONS_ALIGN_TOP = fs.FONS_ALIGN_TOP
FONS_ALIGN_MIDDLE = fs.FONS_ALIGN_MIDDLE
FONS_ALIGN_BOTTOM = fs.FONS_ALIGN_BOTTOM
FONS_ALIGN_BASELINE = fs.FONS_ALIGN_BASELINE
FONS_ZERO_TOPLEFT = fs.FONS_ZERO_TOPLEFT
FONS_ZERO_BOTTOMLEFT = fs.FONS_ZERO_BOTTOMLEFT

cdef class Context:
    cdef fs.FONScontext * ctx
    cdef dict fonts
    def __cinit__(self,atlas_size = (512,512),flags = fs.FONS_ZERO_TOPLEFT):
        self.ctx = fs.glfonsCreate(atlas_size[0],atlas_size[1],flags)

    def __init__(self,atlas_size = (512,512),flags = fs.FONS_ZERO_TOPLEFT):
        self.fonts = {}

    def __dealloc__(self):
        fs.glfonsDelete(self.ctx)

    def add_font(self, bytes name, bytes font_loc):
        cdef int font_id = fs.FONS_INVALID

        font_id = fs.fonsAddFont(self.ctx, name,font_loc)
        if font_id == fs.FONS_INVALID:
            raise Exception("Font could not be loaded from '%s'."%font_loc)
        else:
            self.fonts[name]=font_id

    property fonts:
        def __get__(self):
            return self.fonts

    def set_text_align(self,int align):
        '''
        bitwise or '|' the following:
        FONS_ALIGN_LEFT
        FONS_ALIGN_CENTER
        FONS_ALIGN_RIGHT
        FONS_ALIGN_TOP
        FONS_ALIGN_MIDDLE
        FONS_ALIGN_BOTTOM
        FONS_ALIGN_BASELINE
        '''
        fs.fonsSetAlign(self.ctx,align)

    def set_blur(self,float blur):
        fs.fonsSetBlur(self.ctx,blur)

    def clear_state(self):
        fs.fonsClearState(self.ctx)

    def set_size(self, float size):
        fs.fonsSetSize(self.ctx,size)

    def set_spacing(self, float spacing):
        fs.fonsSetSpacing(self.ctx,spacing)

    def set_font(self,bytes font_name):
        fs.fonsSetFont(self.ctx,self.fonts[font_name])

    def set_font_id(self,int font_id):
        fs.fonsSetFont(self.ctx,font_id)

    def draw_text(self,float x,float y ,bytes text):
        cdef float dx = fs.fonsDrawText(self.ctx,x,y,text,NULL)
        return dx

    def set_color_float(self,float r, float g, float b, float a):
        cdef unsigned int ir,ig,ib,ia,color
        ir = int(r*255)
        ig = int(g*255)
        ib = int(b*255)
        ia = int(a*255)
        color = fs.glfonsRGBA(ir,ig,ib,ia)
        fs.fonsSetColor(self.ctx,color)

    def draw_debug(self,float x,float y):
        fs.fonsDrawDebug(self.ctx,x,y)

