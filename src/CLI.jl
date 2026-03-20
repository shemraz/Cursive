using ArgMacros
using NativeFileDialog
using StyledStrings

function parse_args(ARGS::Vector{String})::@NamedTuple{output::String, difference::Float64, segment_threshold::Float64, colour::Bool, input::Union{String,Nothing}}
    args = @tuplearguments begin
        @argumentdefault String "result.png" output "--output" "-o"
        @arghelp "Path to the output file."

        @argumentdefault Float64 12.5 difference "--difference" "-d"
        @arghelp "Maximum difference from mean background value to remove."

        @argumentdefault Float64 0.2 segment_threshold "--segment_threshold" "-s"
        @arghelp "Threshold for image segmentation algorithm (unseeded region growing). Used to determine mean background value."

        @argumentflag colour "--preserve_colour"
        @arghelp "Skips morphological filtering to preserve colour of ink. Warning: less performant than default."

        @positionaloptional String input "input"
        @arghelp "Path to the input file."

    end
    return args
end

function @main(ARGS)
    args = parse_args(ARGS)
    file = if isnothing(args.input)
        pick_file()
    else
        args.input
    end
    println(styled"{bold,green:Processing} $file")
    img = load(file)
    result = extract!(img; difference=args.difference, threshold=args.segment_threshold, colour=args.colour)
    save(args.output, result)
    println(styled"{bold,green:Success} Saved image to:\n\t$(abspath(args.output))")
    return 0
end
