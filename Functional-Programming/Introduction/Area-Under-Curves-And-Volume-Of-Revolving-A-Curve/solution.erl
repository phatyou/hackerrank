-module(solution).
-export([main/0]).

% Take a line of strings space separated and transform it
% into a List of strings (removing the line break)
lineAsListOfStrings(Line) ->
    re:split(string:strip(Line -- "\n"), " ", [{return,list}]).

% Read the input as a string (line of numbers, space separated)
% and return {ok, ListOfIntegers}
readLineAsList() ->
    case io:get_line("") of
        eof ->
            ok;
        N ->
            {ok, [ list_to_integer(X) || X <- lineAsListOfStrings(N) ]}
    end.

% We are going to build a recursive function to act like the polynomial
% After we use all coefficients and exponents, the break condition for the
% recursion is to return an anonymous function that always returns zero
buildEquation([], []) -> fun(_) -> 0 end;

% Function buildEquation will a function that behaves exactly as the
% polynomial.
% This way we'll build the equation only once for both integrations
buildEquation([Coef|Coefficients], [Exp|Exponents]) ->
    % The second term of the following sum will expand into a similar
    % anonymous function, using the next coefficient and exponent and
    % immediately calling it with X
    fun(X) -> Coef*math:pow(X, Exp) + (buildEquation(Coefficients, Exponents))(X) end.

% Proxy call to integrateArea, to initialize an Accumulator = 0
% and to fix the initial point of integration
integrateArea(Equation, [Begin, End], DeltaX) ->
    integrateArea(Equation, End, DeltaX, Begin, 0).

% Break condition for the recursion
% (the current point is greater than the End limit)
integrateArea(_, End, _, X, Accumulator) when X > End -> Accumulator;

% Calculate the integral. For each point of the interval calculate the area
% under the curve by taking the evaluation of the polynomial at X times
% the length of the increment (DeltaX)
integrateArea(Equation, End, DeltaX, X, Accumulator) ->
    Area = DeltaX*Equation(X),
    integrateArea(Equation, End, DeltaX, X+DeltaX, Accumulator+Area).

% Proxy call to integrateVolume, to initialize an Accumulator = 0
% and to fix the initial point of integration
integrateVolume(Equation, [Begin, End], DeltaX) ->
    integrateVolume(Equation, End, DeltaX, Begin, 0).

integrateVolume(_, End, _, X, Accumulator) when X > End -> Accumulator;

% Calculate the integral. For each point of the interval calculate the volume
% generated by revolvind the area under the curve around the X-axis.
% Each partial volume is a cylinder with height equals to length of the
% increment (DeltaX) and transversal area is a circle with radius equals to
% the evaluation of the polynomial at X
integrateVolume(Equation, End, DeltaX, X, Accumulator) ->
    Volume = DeltaX*math:pow(Equation(X), 2)*math:pi(),
    integrateVolume(Equation, End, DeltaX, X+DeltaX, Accumulator+Volume).

main() ->
    % Get the coefficients
    {ok, Coefficients} = readLineAsList(),
    % Get the exponents
    {ok, Exponents} = readLineAsList(),
    % Get the integration limits
    {ok, Limits} = readLineAsList(),
    % Build the polynomial function
    Equation = buildEquation(Coefficients, Exponents),
    % Calculate and output both integration results
    io:format("~.1f~n", [integrateArea(Equation, Limits, 0.001)]),
    io:format("~.1f~n", [integrateVolume(Equation, Limits, 0.001)]).