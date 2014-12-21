cimport cfontstash as fs


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
    def __cinit__(self,atlas_size = (1024,1024),flags = fs.FONS_ZERO_TOPLEFT):
        self.ctx = fs.glfonsCreate(atlas_size[0],atlas_size[1],flags)

    def __init__(self,atlas_size = (1024,1024),flags = fs.FONS_ZERO_TOPLEFT):
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

    def set_align(self,int align):
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

    def push_state(self):
        fs.fonsPushState(self.ctx)

    def pop_state(self):
        fs.fonsPopState(self.ctx)

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

    cpdef draw_text(self,float x,float y,bytes text):
        cdef float dx = fs.fonsDrawText(self.ctx,x,y,text,NULL)
        return dx

    cpdef draw_limited_text(self, float x, float y, bytes text, float width):
        '''
        draw text limited in width - it will cut off on the right hand side.
        '''
        cdef int idx = len(text)
        cdef bytes clip = <bytes>''
        #fs.fonsPushState(self.ctx)
        #fs.fonsSetAlign(self.ctx,0)
        while idx:
            clip = text[:idx]
            if fs.fonsTextBounds(self.ctx, 0,0, clip, NULL, NULL) <= width:
                break
            idx -=1
        #fs.fonsPopState(self.ctx)
        if idx == 0:
            return x

        if len(text) != len(clip):
            text = text[:idx-1] #+ bytes('..')


        return self.draw_text(x,y,text)

    cpdef get_first_char_idx(self, bytes text, float width):
        '''
        get the clip index for a given width
        '''
        cdef int idx = len(text)
        cdef bytes clip = <bytes>''
        # reverse the text
        text = text[::-1]

        while idx:
            clip = text[:idx]
            if fs.fonsTextBounds(self.ctx, 0,0, clip, NULL, NULL) <= width:
                break
            idx -=1
            
        return len(text)-idx

    cpdef draw_multi_line_text(self, float x, float y, bytes text, float line_height = 1):
        '''
        draw multiple lines of text delimited by "\n"
        '''
        cdef float asc = 0,des = 0,lineh = 0
        fs.fonsVertMetrics(self.ctx, &asc,&des,&lineh)
        line_height *= lineh
        lines = text.split('\n')
        for l in lines:
            fs.fonsDrawText(self.ctx,x,y,l,NULL)
            y += line_height


    cpdef draw_breaking_text(self, float x, float y, bytes text, float width,float height,float line_height = 1):
        '''
        draw a string of text breaking at the bounds.
        '''
        # first we figure out the v space
        cdef float asc = 0,des = 0,lineh = 0
        fs.fonsVertMetrics(self.ctx, &asc,&des,&lineh)
        line_height *= lineh
        cdef float max_y = y + height - line_height

        # second we break the text into lines
        cdef basestring clip
        words = text.split(' ')
        cdef int idx = 1, max_idx = len(words)

        # now we draw words
        while words:
            clip = ' '.join(words[:idx])
            if idx > max_idx or fs.fonsTextBounds(self.ctx, 0,0, clip, NULL, NULL) > width:
                idx = max(0,idx-1)
                clip = ' '.join(words[:idx])
                fs.fonsDrawText(self.ctx,x,y,clip,NULL)
                words = words[idx:]
                y += line_height
                if y > max_y:
                    break
            idx +=1

        return words



    def text_bounds(self,float x,float y, bytes text):
        '''
        get the width of a text
        '''
        cdef float width
        width = fs.fonsTextBounds(self.ctx,x,y,text,NULL,NULL)
        return width

    #todo:
    #fonsLineBounds
    #fonsVertMetrics


    cpdef set_color_float(self,tuple color):
        cdef unsigned int ir,ig,ib,ia,c
        ir = int(color[0]*255)
        ig = int(color[1]*255)
        ib = int(color[2]*255)
        ia = int(color[3]*255)
        c = fs.glfonsRGBA(ir,ig,ib,ia)
        fs.fonsSetColor(self.ctx,c)

    def draw_debug(self,float x,float y):
        fs.fonsDrawDebug(self.ctx,x,y)

