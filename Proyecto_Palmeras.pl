% distancias entre palmeras
palm2palm(jasmine,sheherazade,18).
palm2palm(sheherazade,nina,12).
palm2palm(jasmine,nina,19).
palm2palm(elisa,nina,8).
palm2palm(elisa,sheherazade,20).

% distancias entre una palmera y el pozo
palm2well(jasmine,13).
palm2well(sheherazade,19).
palm2well(nina,22).
palm2well(elisa,34).

% cantidad de agua por palmera
:- dynamic(palm_needs/2).
palm_needs(jasmine,2).
palm_needs(sheherazade,1).
palm_needs(nina,2).
palm_needs(elisa,4).

% tamaño del balde
bucket(5).

% tiempo minimo deseado por el jardinero
desired_time(114).

% Cuando la lista está vacía todas las movidas fueron hechas pero estoy en una palmera
% y el balde tiene agua hago solve_dfs para actualizar el balde
solve_dfs(Estado,[],_,_) :- 
	final_state(Estado).

solve_dfs(Estado,[Movida|Movidas],[Movida|Movidas],Tiempo) :-
      move(Estado,Estado3,Movida),              % generar una nueva Movida
      update(Estado3,Movida,Estado2,Tiempo2),    % calcula nuevo estado usando Movida
      legal(Estado3,Estado2,Movida),                    % nuevo estado debe ser legal
      solve_dfs(Estado2,Movidas,Historia,Tiempo2).  % continuar a partir de nuevo estado

test_dfs(Problema,Historia) :-
      initial_state(Problema,Estado),
	  solve_dfs(Estado,[jasmine,sheherazade,nina,elisa],Historia,Tiempo).

%Estado inicial del problema
initial_state(pwb,pwb(well,Bucket,[jasmine,sheherazade,nina,elisa],[],0)) :-
	Bucket is 0.
	
%Estado final del problema
final_state(pwb(Posicion,Bucket,[],Historia,Tiempo)) :-
	desired_time(TiempoDeseado),
	Tiempo >=TiempoDeseado,
	write('Tiempo: '),write(Tiempo),write('>'),write('Tiempo Deseado:'),write(TiempoDeseado).

%Actualiza la duración, la lista de palmeras y el balde una vez regada la palmera.
update(pwb(Posicion,Bucket,Palmeras,Historia,Tiempo),Movida, pwb(Movida,Bucket2,Palmeras2,Historia2,Tiempo2),Tiempo2):-
	Palmeras \= [],
	update_palmeras(Movida,Palmeras,Palmeras2,Historia,Historia2),
	update_tiempo(Movida,Tiempo,Tiempo2),
	update_bucket(Bucket,Bucket2,Movida). 
	

update_palmeras(Movida,Palmeras,Palmeras2,Historia,Historia2):-
	select(Movida,Palmeras,Palmeras2),
	insert(Movida,Historia,Historia2).

update_tiempo(Movida,Tiempo,Tiempo2):-
	palm_needs(Movida,Cantidad),
	Tiempo2 is Tiempo+Cantidad.

update_bucket(Bucket,Bucket2,Movida):-
	palm_needs(Movida,Cantidad),
	Bucket2 is Bucket-Cantidad.

%Movimiento final si el bucket tiene agua pero ya se regaron las palmeras
%Se procede a ir al pozo y depositar el agua restante, actualizar tiempo.
move(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),pwb(well,BucketFinal,Movidas,Historia,TiempoFinal),Movida):-
	Movidas == [],
	palm2well(Posicion,Cantidad),
	TiempoFinal is Tiempo+Cantidad+Bucket,
	BucketFinal is 0.

%Moverse de una palmera a otra
move(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),pwb(Movida,Bucket,Movidas,Historia,Tiempo2),Movida):-
	%Bucket \= 0,
	palm2palm(Posicion,Movida,Cantidad),
	Tiempo2 is Tiempo+Cantidad.

%Moverse de una palmera a otra
move(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),pwb(Movida,Bucket,Movidas,Historia,Tiempo2),Movida):-
	%Bucket \= 0,
	palm2palm(Movida,Posicion,Cantidad),
	Tiempo2 is Tiempo+Cantidad.

%Llenar el balde cuando está en 0
move(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),pwb(Movida,Bucket2,Movidas,Historia,Tiempo2),Movida):-
	Posicion == well,
	%Bucket == 0,
	bucket(Bucket2),
	palm2well(Movida,Cantidad),
	Tiempo2 is Tiempo+Bucket2+Cantidad.

%Moverse de una palmera al pozo, llenar el balde y volver a la palmera
move(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),pwb(Movida,Bucket2,Movidas,Historia,Tiempo2),Movida):-
	Bucket == 0,
	bucket(Bucket2),
	palm2well(Posicion,Cantidad),
	palm2palm(Posicion,Movida,Cantidad2),
	Tiempo2 is Tiempo+Bucket2+Cantidad+Cantidad+Cantidad2.

%Moverse de una palmera al pozo, llenar el balde y volver a la palmera
move(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),pwb(Movida,Bucket2,Movidas,Historia,Tiempo2),Movida):-
	Bucket == 0,
	bucket(Bucket2),
	palm2well(Posicion,Cantidad),
	palm2palm(Movida,Posicion,Cantidad2),
	Tiempo2 is Tiempo+Bucket2+Cantidad+Cantidad+Cantidad2.

legal(Estado1,Estado,Movida):-
	not(ilegal(Estado1,Estado,Movida)).

%Movimiento ilegal si el bucket no tiene suficiente agua para regar una palmera
ilegal(pwb(_,Bucket1,_,_,_),pwb(Posicion,Bucket,Movidas,Historia,Tiempo),Movida):-
	palm_needs(Posicion,Cantidad),
	Resultado = Bucket1-Cantidad,
	Resultado < 0.

ilegal(pwb(Posicion1,Bucket1,Movidas1,Historia1,Tiempo1),pwb(Posicion,Bucket,Movidas,Historia,Tiempo),Movida):-
	Bucket1 > 0,
	Posicion1 == well,
	Posicion \= well.

	
select(X,[X|Xs],Xs).                          % Extrae primer elemento.
select(X,[Y|Ys],[Y|Zs]):-select(X,Ys,Zs).    % Extrae elemento de más adentro.

insert(X,[Y|Ys],[Y|Zs]):-
    insert(X,Ys,Zs).
insert(X,[],[X]).
	
