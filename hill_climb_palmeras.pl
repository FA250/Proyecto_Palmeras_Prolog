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

% tama�o del balde
bucket(5).

% tiempo minimo deseado por el jardinero
desired_time(114).

% Cuando la lista est� vac�a todas las movidas fueron hechas pero estoy en una palmera
% y el balde tiene agua hago solve_dfs para actualizar el balde
solve_hill_climb(pwb(well,0,[],Resultado,Tiempo),_,_,_) :- 
	final_state(pwb(well,0,[],Resultado,Tiempo)).

solve_hill_climb(Estado,Movidas,Historia,Tiempo) :-
      hill_climb(Estado,Movida),             % generar una nueva Movida
      update(Estado,Movida,Estado2,Tiempo2,Movidas2),    % calcula nuevo estado usando Movida
      legal(Estado2),                    % nuevo estado debe ser legal
      solve_hill_climb(Estado2,Movidas2,Historia,Tiempo2).  % continuar a partir de nuevo estado

test_hill_climb(Problema,Historia) :-
      initial_state(Problema,Estado),
	  solve_hill_climb(Estado,[jasmine,sheherazade,nina,elisa],Historia,Tiempo).

hill_climb(State,Move) :-
    findall(M,move(State,M),Moves),
    evaluate_and_order(Moves,State,[],MVs),
    member((Move,_),MVs).

% Caso: procesar la primera movida y continuar recursivamente
evaluate_and_order([Move|Moves],Estado,MVs,OrderedMVs) :-
    update(Estado,Move,Estado2,Tiempo2,Moves),         % obtiene nuevo estado usando movida
    value(Estado,Move,Value),              % calcula el valor heur�sico del nuevo estado
    insertPair((Move,Value),MVs,MVs1), % inserta en orden el par (movida,valor) en lista de movidas
    evaluate_and_order(Moves,Estado2,MVs1,OrderedMVs).  % procesa recursivamente el resto de movidas

% Caso base: no hay m�s movidas que evaluar. Se retorna el acumulador como resultado.
evaluate_and_order([],_,MVs,MVs).

insertPair(MV,[],[MV]).
insertPair((M,V),[(M1,V1)|MVs],[(M,V),(M1,V1)|MVs]) :-
    V >= V1.
insertPair((M,V),[(M1,V1)|MVs],[(M1,V1)|MVs1]) :-
    V < V1,insertPair((M,V),MVs,MVs1).

value(pwb(well,Bucket,Movidas,Historia,Tiempo),Movida,Cantidad):-
	palm2well(Movida,Cantidad).
value(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),Movida,Cantidad):-
	Bucket ==0,
	Posicion \= well,
	palm2well(Posicion,Cantidad).
value(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),Movida,Cantidad):-
	Bucket \=0,
	Posicion \= well,
	palm2palm(Posicion,Movida,Cantidad).
value(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),Movida,Cantidad):-
	Bucket \=0,
	Posicion \= well,
	palm2palm(Movida,Posicion,Cantidad).

%Estado inicial del problema
initial_state(pwb,pwb(well,Bucket,[jasmine,sheherazade,nina,elisa],[],Bucket)) :-
	 bucket(Bucket).
	
%Estado final del problema
final_state(pwb(_,_,[],Resultado,Tiempo)) :-
	desired_time(TiempoDeseado),
	Tiempo >=TiempoDeseado,
	write('Tiempo: '),write(Tiempo),write('>'),write('Tiempo Deseado:'),write(TiempoDeseado),
	write('\nResultado: '),write(Resultado).

%Actualiza la duraci�n, la lista de palmeras y el balde una vez regada la palmera.
update(pwb(Posicion,Bucket,Palmeras,Historia,Tiempo),Movida, pwb(Movida,Bucket2,Palmeras2,Historia2,Tiempo2),Tiempo2,Palmeras2):-	
	update_palmeras(Movida,Palmeras,Palmeras2,Historia,Historia2),	
	update_bucket(Bucket,Bucket2,Movida,Palmeras),
	update_tiempo(Posicion,Movida,Tiempo,Tiempo2,Palmeras,Bucket). 
	

update_palmeras(well,Palmeras,Palmeras,Historia,Historia).
	
update_palmeras(Movida,Palmeras,Palmeras2,Historia,Historia2):-
	select(Movida,Palmeras,Palmeras2),
	insert(Movida,Historia,Historia2).

update_tiempo(well,Movida,Tiempo,Tiempo2,_,_):-
	palm_needs(Movida,Cantidad),
	palm2well(Movida,Cantidad2),
	Tiempo2 is Tiempo+Cantidad+Cantidad2.
	
update_tiempo(Posicion,well,Tiempo,Tiempo2, Palmeras, Bucket):-	
	Palmeras==[],
	palm2well(Posicion,Cantidad2),
	Tiempo2 is Tiempo+Bucket+Cantidad2.
	
update_tiempo(Posicion,well,Tiempo,Tiempo2,Palmeras,Bucket1):-	
	Palmeras\=[],
	Bucket1==0,
	bucket(Bucket),
	palm2well(Posicion,Cantidad2),
	Tiempo2 is Tiempo+Bucket+Cantidad2.
	
update_tiempo(Posicion,Movida,Tiempo,Tiempo2,_,_):-
	palm_needs(Movida,Cantidad),
	palm2palm(Posicion,Movida,Cantidad2),
	Tiempo2 is Tiempo+Cantidad+Cantidad2.
	
update_tiempo(Posicion,Movida,Tiempo,Tiempo2,_,_):-
	palm_needs(Movida,Cantidad),
	palm2palm(Movida,Posicion,Cantidad2),
	Tiempo2 is Tiempo+Cantidad+Cantidad2.

update_bucket(Bucket,Bucket2,well,Palmeras):-	
	Palmeras==[],
	Bucket2=0.
	
update_bucket(Bucket,Bucket2,well,_):-	
	bucket(Bucket2).
	
update_bucket(Bucket,Bucket2,Movida,_):-
	palm_needs(Movida,Cantidad),
	Bucket2 is Bucket-Cantidad.

%Movimiento final si el bucket tiene agua pero ya se regaron las palmeras
%Se procede a ir al pozo y depositar el agua restante, actualizar tiempo.
move(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),Movida):-
	Movidas == [],
	Movida=well.
	
%Moverse de una palmera al pozo, llenar el balde y volver a la palmera
move(pwb(Posicion,Bucket,Movidas,Historia,Tiempo),Movida):-
	Bucket == 0,
	bucket(Bucket2),
	palm2well(Posicion,Cantidad),
	Movida=well.

%Moverse de una palmera a otra
move(pwb(Posicion,Bucket,[Movida|Movidas],Historia,Tiempo),Movida2):-
	member(Movida2,[Movida|Movidas]),
	Bucket \= 0,
	palm2palm(Posicion,Movida2,Cantidad).
	
move(pwb(Posicion,Bucket,[Movida|Movidas],Historia,Tiempo),Movida2):-
	member(Movida2,[Movida|Movidas]),
	Bucket \= 0,
	palm2palm(Movida2,Posicion,Cantidad).

%Llenar el balde cuando est� en 0
move(pwb(Posicion,_,[Movida|Movidas],Historia,Tiempo),Movida2):-
	member(Movida2,[Movida|Movidas]),
	Posicion == well,
	%Bucket == 0,
	palm2well(Movida2,Cantidad).

legal(Estado):-
	not(ilegal(Estado)).

%Movimiento ilegal si el bucket no tiene suficiente agua para regar una palmera
ilegal(pwb(Posicion,Bucket1,_,_,_)):-		
	Bucket1 < 0.

ilegal(pwb(Posicion,Bucket1,_,_,_)):-
	bucket(Bucket1),
	Posicion \= well.

	
select(X,[X|Xs],Xs).                          % Extrae primer elemento.
select(X,[Y|Ys],[Y|Zs]):-select(X,Ys,Zs).    % Extrae elemento de m�s adentro.

insert(X,[Y|Ys],[Y|Zs]):-
    insert(X,Ys,Zs).
insert(X,[],[X]).