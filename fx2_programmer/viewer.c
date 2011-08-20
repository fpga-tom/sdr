#include <stdio.h>
#include <stdlib.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <GL/glut.h>
#include <math.h>
#include <stdarg.h>
#include <time.h>
#include <unistd.h>

#include "fx2.h"
#include <fftw3.h>

float background[4]={1.0, 1.0, 1.0, 1.0};
float foreground[4]={1.0, 0.0, 0.0, 1.0};

int scope_width, scope_height;
int scope_window;
int scope_x0=0, scope_x1=100;
int fft_x0=0, fft_x1=100;

int fft_width, fft_height;
int fft_window;

/* From fx2.c */
extern int chunks;
extern int stop;

extern unsigned char **buffers;
extern int chunk_size;
extern int last_buffer;
extern int nbuffers;

int old_chunks=-1;
int start_time;
int start_chunks=0;
int next_start_time, next_start_chunks=0;


void do_quit(void)
{
stop=1;
}

void *do_alloc(long a, long b)
{
void *p;
if(a<1)a=1;
if(b<1)b=1;
p=calloc(a,b);
while(p==NULL){
	fprintf(stderr,"Failed to allocate %ld chunks of %ld bytes each (%ld bytes total)\n", a,b,a*b);
	sleep(1);
	p=calloc(a,b);
	}
return p;
}

void glut_printf(void *font, const char *format, ...)
{
va_list ap;
char *s;
int size, new_size;
int i;

va_start(ap, format);

size=1000;
s=do_alloc(size, sizeof(*s));
new_size=vsnprintf(s, size, format, ap);
if(new_size>=size){
	free(s);
	size=new_size+1;
	s=do_alloc(size, sizeof(*s));
	vsnprintf(s, size, format, ap);
	}
va_end(ap);

if((font==GLUT_STROKE_ROMAN) || (font==GLUT_STROKE_MONO_ROMAN)){
	for(i=0;s[i];i++){
		glutStrokeCharacter(font, s[i]);
		}
	} else {
	for(i=0;s[i];i++){
		glutBitmapCharacter(font, s[i]);
		}
	}
}

void redisplay_scope(void)
{
int i, buf, cur_time;

glDrawBuffer(GL_BACK);

glLoadIdentity();

glScalef(2.0/scope_width, 2.0/scope_height, 1.0);
glTranslatef(-scope_width/2.0, -scope_height/2.0, 0.0);

glClearColor(background[0], background[1], background[2], background[3]);
glClearDepth(1.0);

glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

glColor4f(background[0], background[1], background[2], background[3]);

#if 0
glBindTexture(GL_TEXTURE_2D, 0);
glBegin(GL_QUADS);
glVertex2f(0.0, 0.0);
glVertex2f(priv->scope_width, 0.0);
glVertex2f(priv->scope_width, priv->scope_height);
glVertex2f(0.0, priv->scope_height);
glEnd();
#endif

/* Draw grid */
glColor3f(0.5, 0.5, 0.5);

glBegin(GL_LINES);
for(i=0;i<chunk_size;i+=10){
	glVertex2f(1.0+((scope_width-1)*(i-scope_x0))/(scope_x1-scope_x0), scope_height);
	glVertex2f(1.0+((scope_width-1)*(i-scope_x0))/(scope_x1-scope_x0), 0.0);
	}
glEnd();

glColor3f(0.0, 0.0, 0.0);

glBegin(GL_LINES);
for(i=0;i<chunk_size;i+=100){
	glVertex2f(1.0+((scope_width-1)*(i-scope_x0))/(scope_x1-scope_x0), scope_height);
	glVertex2f(1.0+((scope_width-1)*(i-scope_x0))/(scope_x1-scope_x0), 0.0);
	}
glEnd();

glColor3f(0.0, 0.5, 0.5);
for(i=0;i<chunk_size;i+=100){
	glRasterPos2f(3.0+((scope_width-1)*(i-scope_x0))/(scope_x1-scope_x0), 0.0);
	glut_printf(GLUT_BITMAP_HELVETICA_18, "%d", i);
	}

/* Draw curve */

buf=last_buffer-1;
if(buf<0)buf=nbuffers-1;

glColor3f(foreground[0], foreground[1], foreground[2]);

glBegin(GL_LINE_STRIP);
for(i=scope_x0;i<scope_x1;i++){
	glVertex2f(1.0+((scope_width-1)*(i-scope_x0))/(scope_x1-scope_x0), 1.0+((scope_height-1)*buffers[buf][i])/256.0);
	}
glEnd();

glColor3f(0.0, 0.0, 1.0);

glRasterPos2f(0.0, fft_height-18);
glut_printf(GLUT_BITMAP_HELVETICA_18, "255");

glRasterPos2f(0.0, 0.0);
glut_printf(GLUT_BITMAP_HELVETICA_18, "0");


glRasterPos2f(fft_width-200, fft_height-18);
cur_time=time(NULL);

if(cur_time-next_start_time>20){
	start_chunks=next_start_chunks;
	start_time=next_start_time;

	next_start_chunks=chunks;
	next_start_time=time(NULL);
	}

glut_printf(GLUT_BITMAP_HELVETICA_18, "%f KB/sec\n", (1.0*chunk_size*(chunks-start_chunks))/(1024.0*(cur_time-start_time)));

glutSwapBuffers();
}

void new_geometry_scope(int w, int h)
{

scope_width=w;
scope_height=h;

glViewport(0, 0, w, h);

glutPostRedisplay();
}

void special_keypress_scope(int key, int x, int y)
{
int step;

switch(key){
	case GLUT_KEY_DOWN:
		scope_x1=scope_x1/1.5;
		if(scope_x1<20)scope_x1=20;
		break;
	case GLUT_KEY_UP:
		scope_x1*=1.5;
		if(scope_x1>=chunk_size)scope_x1=chunk_size-1;
		break;
	case GLUT_KEY_LEFT:
		step=5.0*(scope_x1-scope_x0)/scope_width;
		if(step<1)step=1;
		if(scope_x0>=step){
			scope_x0-=step;
			scope_x1-=step;
			}
		break;
	case GLUT_KEY_RIGHT:
		step=5.0*(scope_x1-scope_x0)/scope_width;
		if(step<1)step=1;
		if(scope_x0<chunk_size-step-5){
			scope_x0+=step;
			scope_x1+=step;
			}
		break;
	case GLUT_KEY_HOME:
		scope_x0=0;
		scope_x1=chunk_size;
		break;
	case GLUT_KEY_END:
		break;
	default:
		fprintf(stderr, "special key pressed: key=%c (%d) at (%d, %d)\n", key, key, x, y);	
	}
glutPostRedisplay();
}

void keypress_scope(unsigned char key, int x, int y)
{

switch(key){
	case 27: /* escape */
		do_quit();
		break;
	case 8:  /* backspace */
		break;
	case 127: /* delete */
		break;
	default:
		fprintf(stderr, "key pressed: key=%c (%d) at (%d, %d)\n", key, key, x, y);
	}
glutPostRedisplay();			
}


/* ------------- FFT ------------------*/

fftw_plan dft_plan;
double *buffer_d;
fftw_complex *fft;
double *power;

void init_fft(void)
{
int i;

buffer_d=fftw_malloc(chunk_size*sizeof(*buffer_d));
fft=fftw_malloc((chunk_size/2+1)*sizeof(*fft));
power=do_alloc(chunk_size/2+1, sizeof(*power));

fprintf(stderr, "Creating FFT plan\n");
dft_plan=fftw_plan_dft_r2c_1d(chunk_size, buffer_d, fft, FFTW_MEASURE);
fprintf(stderr, "Created FFT plan\n");

for(i=0;i<chunk_size/2+1;i++)power[i]=0;

}

void redisplay_fft(void)
{
int i, buf;
double max_power=0.0, min_power=0.0, gap;

glDrawBuffer(GL_BACK);

glLoadIdentity();

glScalef(2.0/fft_width, 2.0/fft_height, 1.0);
glTranslatef(-fft_width/2.0, -fft_height/2.0, 0.0);

glClearColor(background[0], background[1], background[2], background[3]);
glClearDepth(1.0);

glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

glColor4f(background[0], background[1], background[2], background[3]);

#if 0
glBindTexture(GL_TEXTURE_2D, 0);
glBegin(GL_QUADS);
glVertex2f(0.0, 0.0);
glVertex2f(priv->fft_width, 0.0);
glVertex2f(priv->fft_width, priv->fft_height);
glVertex2f(0.0, priv->fft_height);
glEnd();
#endif

/* Draw grid */
glColor3f(0.5, 0.5, 0.5);

glBegin(GL_LINES);
for(i=0;i<chunk_size;i+=10){
	glVertex2f(1.0+((fft_width-1)*(i-fft_x0))/(fft_x1-fft_x0), fft_height);
	glVertex2f(1.0+((fft_width-1)*(i-fft_x0))/(fft_x1-fft_x0), 0.0);
	}
glEnd();

glColor3f(0.0, 0.0, 0.0);

glBegin(GL_LINES);
for(i=0;i<chunk_size;i+=100){
	glVertex2f(1.0+((fft_width-1)*(i-fft_x0))/(fft_x1-fft_x0), fft_height);
	glVertex2f(1.0+((fft_width-1)*(i-fft_x0))/(fft_x1-fft_x0), 0.0);
	}
glEnd();

glColor3f(0.0, 0.5, 0.5);
for(i=0;i<chunk_size;i+=100){
	glRasterPos2f(3.0+((fft_width-1)*(i-fft_x0))/(fft_x1-fft_x0), 0.0);
	glut_printf(GLUT_BITMAP_HELVETICA_18, "%d", i);
	}
	
/* Compute FFT */
buf=last_buffer-1;
if(buf<0)buf=nbuffers-1;

/* Copy data into double buffer (excessive, but ok for now)
  and apply Hann window */
  /* note the result has power that is 3 times bigger than what it should be */
for(i=0;i<chunk_size;i++)buffer_d[i]=buffers[buf][i]*(1-cos(2.0*M_PI*i/(chunk_size-1)));

fftw_execute(dft_plan);
for(i=0;i<chunk_size/2+1;i++){
	#if 0
	power[i]=power[i]*0.9+0.1*log10(1.0+sqrt(fft[i][0]*fft[i][0]+fft[i][1]*fft[i][1]));
	power[i]=power[i]*0.9+0.1*sqrt(fft[i][0]*fft[i][0]+fft[i][1]*fft[i][1]);
	#endif
	power[i]=sqrt(2.0*(fft[i][0]*fft[i][0]+fft[i][1]*fft[i][1])/3.0)/chunk_size;
	if((i>=fft_x0)&&(i<=fft_x1)){
		if((i==fft_x0) || (power[i]>max_power))max_power=power[i];
		if((i==fft_x0) || (power[i]<min_power))min_power=power[i];
		}
	}

/* Draw periodogram */

glColor3f(foreground[0], foreground[1], foreground[2]);

/* fprintf(stderr, "max_power=%f min_power=%f\n", max_power, min_power); */

/* Rationalize max_power and min_power */
if(min_power>=max_power)max_power=min_power+1.0;

gap=max_power-min_power;
gap=exp(log(10.0)*floor(log10(gap)));

min_power=floor(min_power/gap)*gap;
max_power=min_power+ceil((max_power-min_power)/gap)*gap;


glBegin(GL_LINE_STRIP);
for(i=00;i<chunk_size/2+1;i++){
	glVertex2f(1.0+((fft_width-1)*(i-fft_x0))/(fft_x1-fft_x0), 1.0+((fft_height-1)*(power[i]-min_power))/(max_power-min_power));
	}
glEnd();

#if 0
glBegin(GL_LINES);
glVertex2f(-1.0, -1.0);
glVertex2f(1.0, 1.0);
glEnd();
#endif

//glTranslatef(0.0, priv->fft_height, 0.0);

/* Draw max and min labels */

glColor3f(0.0, 0.0, 1.0);

glRasterPos2f(0.0, fft_height-18);
glut_printf(GLUT_BITMAP_HELVETICA_18, "%f", max_power);

glRasterPos2f(0.0, 0.0);
glut_printf(GLUT_BITMAP_HELVETICA_18, "%f", min_power);

glutSwapBuffers();
}

void new_geometry_fft(int w, int h)
{

fft_width=w;
fft_height=h;

glViewport(0, 0, w, h);

glutPostRedisplay();
}

void special_keypress_fft(int key, int x, int y)
{
int step;

switch(key){
	case GLUT_KEY_DOWN:
		fft_x1=fft_x1/1.5;
		if(fft_x1<20)fft_x1=20;
		break;
	case GLUT_KEY_UP:
		fft_x1*=1.5;
		if(fft_x1>chunk_size/2+20)fft_x1=chunk_size/2+20;
		break;
	case GLUT_KEY_LEFT:
		step=5.0*(fft_x1-fft_x0)/fft_width;
		if(step<1)step=1;
		if(fft_x0>=step){
			fft_x0-=step;
			fft_x1-=step;
			}
		break;
	case GLUT_KEY_RIGHT:
		step=5.0*(fft_x1-fft_x0)/fft_width;
		if(step<1)step=1;
		if(fft_x0<chunk_size/2-step-5){
			fft_x0+=step;
			fft_x1+=step;
			}
		break;
	case GLUT_KEY_HOME:
		fft_x0=0;
		fft_x1=chunk_size/2+1;
		break;
	case GLUT_KEY_END:
		break;
	default:
		fprintf(stderr, "special key pressed: key=%c (%d) at (%d, %d)\n", key, key, x, y);
	}
glutPostRedisplay();
}

void keypress_fft(unsigned char key, int x, int y)
{

switch(key){
	case 27: /* escape */
		do_quit();
		break;
	case 8:  /* backspace */
		break;
	case 127: /* delete */
		break;
	default:
		fprintf(stderr, "key pressed: key=%c (%d) at (%d, %d)\n", key, key, x, y);
	}
glutPostRedisplay();			
}

void idle(void)
{
glutPostRedisplay();
}

void timer(int value)
{
if(old_chunks!=chunks){
	glutSetWindow(scope_window);
	glutPostRedisplay();

	glutSetWindow(fft_window);
	glutPostRedisplay();

	#if 0
	fprintf(stderr, "%f KB/sec\n", (10.0*chunk_size*(chunks-old_chunks))/1024.0);
	fprintf(stderr, "\t%f KB/sec\n", (1.0*chunk_size*chunks)/(1024.0*(time(NULL)-start_time)));
	#endif

	old_chunks=chunks;
	}
glutTimerFunc(500, timer, value+1);
}

void init_gl(void)
{
glShadeModel(GL_SMOOTH);
glClearColor(0.0, 0.0, 0.0, 1.0);
glClearDepth(1.0);
//glEnable(GL_DEPTH_TEST);
//glDepthFunc(GL_LEQUAL);
glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//glEnable(GL_TEXTURE_2D);
//glEnable(GL_BLEND);
//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

int main(int argc, char *argv[])
{

glutInit(&argc, argv);

if(argc<4){
	fprintf(stderr, "\nUsage: %s bus device endpoint\n\n", argv[0]);
	exit(-1);
	}

init_buffers();
init_fft();

glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH);  

  /* get a 640 x 480 window */
glutInitWindowSize(1280, 480);  

scope_window=glutCreateWindow("Scope viewer");
glutSetWindow(scope_window);

glutDisplayFunc(&redisplay_scope);
glutReshapeFunc(&new_geometry_scope);
glutKeyboardFunc(&keypress_scope);
glutSpecialFunc(&special_keypress_scope);
//glutIdleFunc(idle);

fft_window=glutCreateWindow("FFT viewer");
glutSetWindow(fft_window);

glutDisplayFunc(&redisplay_fft);
glutReshapeFunc(&new_geometry_fft);
glutKeyboardFunc(&keypress_fft);
glutSpecialFunc(&special_keypress_fft);

start_time=time(NULL);
next_start_time=start_time;

start_usb_reader(argv[1], argv[2], argv[3]);

glutTimerFunc(400, timer, 1);

glutMainLoop();

return 0;
}
