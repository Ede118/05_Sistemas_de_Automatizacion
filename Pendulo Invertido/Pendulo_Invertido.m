%[text] # Péndulo Invertido
%[text] ## Modelo del sistema
%[text] Se tiene un simple péndulo invertido tal que:
%[text] (insertar imagen)
%[text] Primero, se diseña el modelo dinámico, utilizando ecuaciones de Lagrange. Se definen la energía cinética y potencial como:
%[text]{"align":"center"} $\\begin{array}{rl} K & =\\frac{1}{2}m\_{1} \\dot{x}\_{1}^{2} + \\frac{1}{2}m\_{2}v\_{2}^{2}+\\frac{1}{2}I\_{2}\\omega\_{2}^{2} \\\\ U & = -mg\\ell \\cos(\\theta(t)) \\end{array}$
%[text] donde se definen:
%[text]{"align":"center"} $\\begin{array}{ll} \\dot{x}\_{1} & \\text{Velocidad en el eje X del carrito} \\\\ \\dot{y}\_{1}=0 & \\text{Velocidad en el eje Y del carrito} \\\\ \\\\ \\dot{x}\_{2} & \\text{Velocidad en el eje X de la masa del pendulo} \\\\ \\dot{y}\_{2} & \\text{Velocidad en el eje Y de la masa del pendulo} \\\\ v\_{2}^{2}= \\dot{x}\_{2}^{2} + \\dot{y}\_{2}^{2} & \\text{Velocidad de la masa del pendulo} \\\\ \\\\ \\theta & \\text{Angulo del péndulo respecto a la vertical descendiente} \\\\ \\dot{\\theta}=\\omega & \\text{Velocidad angular del péndulo} \\\\ \\end{array}$
%[text] El carrito no tiene movimiento vertical, ergo $\\dot{y}\_{1}=0$. Luego, la masa del péndulo realiza movimiento rototraslacional (rotación y traslación simultánea) por lo que aporta energía cinética traslacional y energía cinética rotacional. Se puede ver que la posición de la masa del péndulo se puede calcular como:
%[text]{"align":"center"} $\\begin{array}{rl} x\_{2} & = x\_{1} + \\ell \\sin(\\theta) \\\\ y\_{2} & = -\\ell \\cos(\\theta) \\end{array}$
%[text] derivando respecto al tiempo, se puede obtener las velocidades de la masa del péndulo
%[text]{"align":"center"} $\\begin{array}{rl} \\frac{d x\_{2} }{dt} & = \\dot{x}\_{1} + \\ell \\cos(\\theta) \\dot{\\theta} \\\\ \\\\ \\frac{d y\_{2} }{dt} & = \\ell \\sin (\\theta) \\dot{\\theta} \\end{array}$
%[text] Por propiedad vectorial de la velocidad, el cuadrado del módulo de la velocidad será:
%[text]{"align":"center"} $\\begin{array}{rl} v\_{2}^{2} & = \\left( \\frac{d x\_{2} }{dt} \\right)^{2} + \\left( \\frac{d y\_{2} }{dt} \\right)^{2} \\\\ \\\\ & = \\Big( \\dot{x}\_{1} + \\ell \\cos(\\theta) \\dot{\\theta} \\Big)^{2} + \\Big( \\ell \\sin (\\theta) \\dot{\\theta} \\Big)^{2} \\\\ \\\\ & = \\dot{x}\_{1}^{2} +\\ell^{2}\\dot{\\theta}^{2} + 2\\ell \\dot{x}\_{1} \\dot{\\theta} \\cos(\\theta) \\end{array}$
%[text] con lo que la energía cinética del sistema queda tal que:
%[text]{"align":"center"} $\\begin{array}{rl} K & = \\\\ & +\\frac{1}{2} \\Big\[ m\_{1}+m\_{2} \\Big\] \\dot{x}\_{1}^{2} \\\\ & + \\frac{1}{2} \\Big\[ m\_{2}\\ell^{2} + I\_{2} \\Big\] \\dot{\\theta}^{2} \\\\ & + \\Big\[ \\ell m\_{2} \\cos(\\theta) \\Big\] \\dot{x}\_{1} \\dot{\\theta} \\end{array}$
%[text] la energía potencial será
%[text]{"align":"center"} $U = -m\_{2} g \\ell \\cos(\\theta(t))$
%[text] y el lagrangiano quedará
%[text]{"align":"center"} $\\begin{array}{rl} L = &  K-U \\\\ = & +\\frac{1}{2} \\Big\[ m\_{1}+m\_{2} \\Big\] \\dot{x}\_{1}^{2} \\\\ & + \\frac{1}{2} \\Big\[ m\_{2}\\ell^{2} + I\_{2} \\Big\] \\dot{\\theta}^{2} \\\\ & + \\Big\[ \\ell m\_{2} \\cos(\\theta) \\Big\] \\dot{x}\_{1} \\dot{\\theta} \\\\ & + g\\Big\[ m\_{2}\\ell \\cos(\\theta) \\Big\] \\end{array}$
%[text] Luego, las derivadas parciales del lagrangiano quedan
%[text]{"align":"center"} $\\begin{array}{rl} \\frac{ \\partial L }{ \\partial \\dot{x}\_{1} } & = \\Big\[ m\_{1}+m\_{2} \\Big\] \\dot{x}\_{1} + \\Big\[ m\_{2}\\ell \\cos(\\theta) \\Big\] \\dot{\\theta} \\\\ \\frac{d  }{dt} \\Bigg( \\frac{ \\partial L }{ \\partial \\dot{x}\_{1} }  \\Bigg) & = \\Big\[ m\_{1}+m\_{2} \\Big\]\\ddot{x}\_{1} + m\_{2}\\ell \\Big\[  \\ddot{\\theta}\\cos(\\theta)-\\dot{\\theta}^{2}\\sin(\\theta) \\Big\]  \\\\ \\\\ \\frac{ \\partial L }{ \\partial \\dot{\\theta} } & = \\Big\[ m\_{2}\\ell^{2}+I\_{2} \\Big\] \\dot{\\theta} + \\Big\[ m\_{2}\\ell \\cos(\\theta) \\Big\] \\dot{x}\_{1} \\\\ \\frac{d  }{dt} \\Bigg( \\frac{ \\partial L }{ \\partial \\dot{\\theta} }  \\Bigg) & = \\Big\[ m\_{2}\\ell^{2}+I\_{2} \\Big\] \\ddot{\\theta} + m\_{2}\\ell \\Big\[  \\ddot{x}\\cos(\\theta)-\\dot{\\theta}\\dot{x}\_{1}\\sin(\\theta) \\Big\]   \\\\ \\\\ \\frac{ \\partial L }{ \\partial x\_{1} } & = 0  \\\\ \\frac{ \\partial L }{ \\partial \\theta } & = -m\_{2}\\ell \\dot{x}\_{1} \\dot{\\theta} \\sin(\\theta) - m\_{2}g \\ell \\sin (\\theta)  \\end{array}$
%[text] y finalmente, las ecuaciones de movimiento quedan tal que:
%[text]{"align":"center"} $\\begin{array}{rl} \\Big\[ m\_{1}+m\_{2} \\Big\] \\ddot{x}\_{1} + \\Big\[ m\_{2}\\ell \\cos(\\theta) \\Big\] \\ddot{\\theta} + \\Big\[ -m\_{2}\\ell \\sin(\\theta)\\dot{\\theta} \\Big\] \\dot{\\theta}  & = F\_{1} \\\\ \\\\ \\Big\[ m\_{2}\\ell \\cos(\\theta) \\Big\] \\ddot{x}\_{1} + \\Big\[ m\_{2}\\ell^{2}+I\_{2} \\Big\] \\ddot{\\theta} + m\_{2}g \\ell \\sin (\\theta)  & = 0 \\end{array}$
%[text] que en forma matricial queda:
%[text]{"align":"center"} $\\left\\lbrack \\begin{array}{c} F\_1 \\\\ 0 \\end{array} \\right\\rbrack = \\left\\lbrack \\begin{array}{cc} m\_1+m\_2 & m\_2\\ell\\cos(\\theta) \\\\ m\_2\\ell\\cos(\\theta) & m\_2\\ell^{2}+I\_2 \\end{array} \\right\\rbrack \\left\\lbrack \\begin{array}{c} \\ddot{x}\_1 \\\\ \\ddot{\\theta} \\end{array} \\right\\rbrack + \\left\\lbrack \\begin{array}{c} -m\_2\\ell\\sin(\\theta)\\dot{\\theta}^{2} \\\\ 0 \\end{array} \\right\\rbrack + g \\left\\lbrack \\begin{array}{c} 0 \\\\ m\_2\\ell\\sin(\\theta) \\end{array} \\right\\rbrack $
%[text] ## Retroalimentación No Lineal: Introducción de Ley de Control PID
%[text] La técnica de Retroalimentación No Lineal no forma parte de los saberes de la cátedra, por lo que simplemente se aplicará sin mucha explicación.
%[text] Básicamente, se despeja la aceleración del carrito y se introduce el despeje en la ecaución de movimiento del péndulo. Esto es:
%[text]{"align":"center"} $\\Big\[ m\_{1}+m\_{2} \\Big\] \\ddot{x} + \\Big\[ m\_{2}\\ell \\cos(\\theta) \\Big\] \\ddot{\\theta} + \\Big\[ -m\_{2}\\ell \\sin(\\theta)\\dot{\\theta} \\Big\] \\dot{\\theta}  = F \\Longrightarrow \\ddot{x} = \\frac{F+m\_{2} \\ell  \\sin (\\theta) \\ \\dot{\\theta}^{2} - m\_{2}\\ell \\cos (\\theta)  \\ddot{\\theta}}{m\_{1}+m\_{2}}$
%[text] reemplazando en la ecuación de movimiento del péndulo
%[text]{"align":"center"} $\\Big\[ m\_{2}\\ell \\cos(\\theta) \\Big\] \\frac{F+m\_{2} \\ell  \\sin (\\theta) \\ \\dot{\\theta}^{2} - m\_{2}\\ell \\cos (\\theta)  \\ddot{\\theta}}{m\_{1}+m\_{2}} + \\Big\[ m\_{2}\\ell^{2}+I\_{2} \\Big\] \\ddot{\\theta} + m\_{2}g \\ell \\sin (\\theta)  = 0$
%[text] se utilizan las siguientes notaciones:
%[text]{"align":"center"} $\\begin{array}{rl} k & = m\_{2}\\ell \\\\ c\_{\\theta} & = \\cos(\\theta) \\\\ s\_{\\theta} & = \\sin (\\theta) \\\\ M & = m\_{1}+m\_{2} \\\\ J & = m\_{2}\\ell^{2}+I\_{2}  \\end{array}$
%[text] lo que deja la ecuación tal que
%[text]{"align":"center"} $kc\_{\\theta} \\cdot \\frac{F+ks\_{\\theta} \\dot{\\theta}^{2}-kc\_{\\theta}\\ddot{\\theta}}{M} + J \\ddot{\\theta} + kgs\_{\\theta} = 0$
%[text] despejando la aceleración angular, se llega a
%[text]{"align":"center"} $\\ddot{\\theta} = \\frac{\\Big( k^{2}c\_{\\theta}s\_{\\theta} \\Big)\\dot{\\theta}^{2}+\\Big( Mks\_{\\theta} \\Big) g + \\Big( kc\_{\\theta} \\Big) F}{k^{2}c\_{\\theta}^{2}-MJ}$
%[text] Esto nos permite analizar la aceleración del péndulo como dos funciones: una que responde al sistema cuando no existe excitación externa y otra que describe la influencia de la excitación del carrito en la aceleración del péndulo
%[text]{"align":"center"} $\\ddot{\\theta} =h(\\theta, \\dot{\\theta}) + b(\\theta) F$
%[text] donde
%[text]{"align":"center"} $\\begin{array}{rl} h(\\theta, \\dot{\\theta})  & = \\frac{\\Big( k^{2}c\_{\\theta}s\_{\\theta} \\Big)\\dot{\\theta}^{2}+\\Big( Mks\_{\\theta} \\Big) g }{k^{2}c\_{\\theta}^{2}-MJ} \\\\ \\\\ b(\\theta) & = \\frac{  kc\_{\\theta}  }{k^{2}c\_{\\theta}^{2}-MJ} \\end{array}$
%[text] Sabiendo la dinámica del péndulo invertido, si se buscara que la aceleración angular siguiera una consigna de valor $\\ddot{\\theta} = \\alpha$ podemos ver que la fuerza F debe tener valor:
%[text]{"align":"center"} $F = \\frac{1}{b(\\theta)} \\Big\[ \\alpha-h(\\theta, \\dot{\\theta}) \\Big\]$
%[text] reemplazando en la ecuación dinámica, se tiene
%[text]{"align":"center"} $\\begin{array}{rl} \\ddot{\\theta}  & = h(\\theta, \\dot{\\theta}) + b(\\theta) \\Big\[ \\frac{1}{b(\\theta)} \\cdot \\Big( \\alpha-h(\\theta,\\dot{\\theta}) \\Big) \\Big\] \\\\ \\ddot{\\theta} & =\\alpha \\end{array}$
%[text] Lo que nos interesa a nosotros en cuestión es que el péndulo cumpla una **consigna de posición angular** $\\theta=\\theta\_{r}$.
%[text] **Diseño de la acción proporcional y derivativa**
%[text] Se considera una referencia angular constante $\\theta\_r$. Para mantener el péndulo en la posición vertical superior, con la convención angular utilizada:
%[text]{"align":"center"} $\\theta\_r=\\pi.$
%[text] Se define el error:
%[text]{"align":"center"} $e=\\theta\_r-\\theta.$
%[text] Como la referencia es constante:
%[text]{"align":"center"} $\\dot e=-\\dot{\\theta}, \\qquad \\ddot e=-\\ddot{\\theta}=-\\alpha.$
%[text] Se desea que el error converja a cero con una dinámica de segundo orden:
%[text]{"align":"center"} $ \\ddot e+2\\zeta\\omega\_n\\dot e+\\omega\_n^2e=0$
%[text] donde $\\zeta\>0$ es el factor de amortiguamiento y $\\omega\_n\>0$ es la frecuencia natural.
%[text] Esta ecuación se elige como objetivo de diseño. Es de segundo orden porque la entrada virtual $\\alpha$ actúa sobre la segunda derivada del ángulo y, por lo tanto, del error.
%[text] Sustituyendo $\\ddot e=-\\alpha$, se obtiene la ley necesaria para lograr ese comportamiento:
%[text]{"align":"center"} $\\alpha=\\omega\_n^2e+2\\zeta\\omega\_n\\dot e.$
%[text] Definiendo:
%[text]{"align":"center"} $K\_P=\\omega\_n^2, \\qquad K\_D=2\\zeta\\omega\_n,$
%[text] resulta un controlador proporcional-derivativo:
%[text]{"align":"center"} $\\alpha=K\_Pe+K\_D\\dot e.$
%[text] La fuerza que debe aplicar el actuador es entonces:
%[text]{"align":"center"} $F= \\frac{ K\_P(\\theta\_r-\\theta)-K\_D\\dot{\\theta} -h(\\theta,\\dot{\\theta}) }{ b(\\theta) }. $
%[text] La acción proporcional solicita una aceleración dirigida a reducir el error angular. La acción derivativa permite frenar el movimiento y regular el amortiguamiento.
%[text] El polinomio característico de la dinámica del error es:
%[text]{"align":"center"} $s^2+K\_Ds+K\_P =s^2+2\\zeta\\omega\_ns+\\omega\_n^2.$
%[text] Para $K\_P\>0$ y $K\_D\>0$, sus polos tienen parte real negativa y el error converge a cero en el modelo ideal compensado.
%[text] Así, las ganancias permiten seleccionar la rapidez y el amortiguamiento de la respuesta angular. No obstante, una respuesta más rápida suele exigir mayores fuerzas, por lo que la elección debe respetar la capacidad del actuador.
%[text] **Incorporación de la acción integral**
%[text] En el modelo ideal, el controlador PD anterior permite alcanzar una referencia constante sin error estacionario. Sin embargo, una perturbación persistente o una compensación imperfecta pueden generar un error residual.
%[text] Para estudiar este efecto, se introduce una perturbación equivalente $d(t)$ en la dinámica angular compensada:
%[text]{"align":"center"} $\\ddot{\\theta}=\\alpha+d(t).$
%[text] Esta perturbación representa un efecto dinámico no compensado; no debe confundirse directamente con el ruido de medición.
%[text] Con el controlador PD, la ecuación del error resulta:
%[text]{"align":"center"} $\\ddot e+K\_D\\dot e+K\_Pe=-d(t).$
%[text] Si $d(t)=d\_0$ es constante, el error de equilibrio es:
%[text]{"align":"center"} $e\_{\\mathrm{eq}}=-\\frac{d\_0}{K\_P}.$
%[text] Para eliminar ese error ante una perturbación equivalente constante se incorpora la integral:
%[text]{"align":"center"} $\\dot z=e, \\qquad z(t)=z(0)+\\int\_0^t e(\\tau)\\,d\\tau.$
%[text] La ley PID que genera la aceleración virtual es:
%[text]{"align":"center"} $\\alpha=K\_Pe+K\_D\\dot e+K\_Iz. $
%[text] En consecuencia, la ley de fuerza completa queda:
%[text]{"align":"center"} $F= \\frac{ K\_P(\\theta\_r-\\theta)-K\_D\\dot{\\theta}+K\_Iz -h(\\theta,\\dot{\\theta}) }{ b(\\theta) }, \\qquad \\dot z=\\theta\_r-\\theta. $
%[text] La dinámica del error es:
%[text]{"align":"center"} $\\ddot e+K\_D\\dot e+K\_Pe+K\_Iz=-d(t), \\qquad \\dot z=e.$
%[text] Para una perturbación constante, un equilibrio de este sistema cumple:
%[text]{"align":"center"} $e\_{\\mathrm{eq}}=0, \\qquad z\_{\\mathrm{eq}}=-\\frac{d\_0}{K\_I}.$
%[text] La acción integral conserva la corrección necesaria para compensar la perturbación, aun cuando el error angular se anula.
%[text] ## Código
dx_init = 0;
dtheta_init = 0;

x_init  = 0;
% theta_init = pi/4;
theta_init = pi - 20 * pi/180;


m1 = 1;
m2 = 1;
I  = 1;
l  = 1;
c_theta = 1;

M = m1+m2;
J = m2*l*l + I;
k = m2*l;
g  = 9.80665;

%%\ Ganancias de traslación
omega_x = 6;
zeta_x  = 0.9;

Kpx     = omega_x^2/g;
Kdx     = 2*zeta_x*omega_x/g;
Kix     = 0;


%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
