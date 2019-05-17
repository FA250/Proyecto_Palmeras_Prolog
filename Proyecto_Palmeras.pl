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
desired_time(12).

solve_dfs(Estado,[Movida|Movidas],Historia,Tiempo) :-
      %move(Estado,Movida),              % generar una nueva Movida
      update(Estado,Movida,Estado2,Tiempo2),    % calcula nuevo estado usando Movida
      %legal(Estado2),                    % nuevo estado debe ser legal
      solve_dfs(Estado2,Movidas,[Movida|Historia],Tiempo2).  % continuar a partir de nuevo estado

test_dfs(Problema,Movidas,Tiempo) :-
      initial_state(Problema,Estado),
	  solve_dfs(Estado,[jasmine,sheherazade,nina,elisa],Movidas,Tiempo).

%Estado inicial del problema
initial_state(pwb,pwd(well,Bucket,[jasmine,sheherazade,nina,elisa],[],0)) :-
	bucket(Bucket).
	
%Estado final del problema
final_state(pwb,Movidas,Bucket) :-
	Bucket == 0,
	Movidas == [].

%Actualiza la duración, la lista de palmeras y el balde una vez regada la palmera.
update(pwb(Posicion,Bucket,Palmeras,Historia,Tiempo),Movida, pwb(Posicion2,Bucket2,Palmeras2,Historia2,Tiempo2),Tiempo2):-
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
	
select(X,[X|Xs],Xs).                          % Extrae primer elemento.
select(X,[Y|Ys],[Y|Zs]):-select(X,Ys,Zs).    % Extrae elemento de más adentro.

insert(X,[Y|Ys],[Y|Zs]):-
    insert(X,Ys,Zs).
insert(X,[],[X]).
	