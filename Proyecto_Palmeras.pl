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
:- dynamic(bucket/1).
bucket(5).

% tiempo acumulado
:- dynamic(duration/1).
duration(0).

% tiempo minimo deseado por el jardinero
desired_time(12).

%Estado inicial del problema
initial_state(pwb,pwb(bucket(Y),duration(X),[jasmine,sheherazade,nina,elisa],[])) :-
	bucket(B),
	B == 5,
	Y is B,
	duration(D),
	D == 0,
	X is D.
	
%Estado final del problema
final_state(pwb,pwb(bucket(Y),duration(X),[],[jasmine,sheherazade,nina,elisa])) :-
	desired_time(Dt),
	duration(D),
	D >= Dt,
	bucket(B),
	B == 0,
	Y is B,
	X is D.

%Actualiza la duración, la lista de palmeras y el balde una vez regada la palmera.
update(Palm, Water):- 
	palm_needs(Palm,Z), 
	Z\=0, 
	Water-Z >=0, 
	Y is -(Z-Water),
	duration(T),
	D is T+Z,
	updatePalmsNeed(palm_needs(Palm,Z), palm_needs(Palm,0)),
	updateDuration(duration(T),duration(D)),
	updateBucket(bucket(Water),bucket(Y)).

updatePalmsNeed(PalmBefore, PalmAfter) :- 
	retract(PalmBefore), 
	assertz(PalmAfter).

updateBucket(BucketBefore,BucketAfter) :- 
	retract(BucketBefore), 
	assertz(BucketAfter).

updateDuration(DurationBefore,DurationAfter):- 
	retract(DurationBefore), 
	assertz(DurationAfter).