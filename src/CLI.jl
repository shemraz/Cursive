using ArgMacros

function parse_args(ARGS)
    args = @tuplearguments begin
        @argumentdefault Float64 12.5 difference "--difference" "-d"
        @arghelp "Maximum difference from mean background value to remove."

        @argumentdefault Float64 0.2 segment_threshold "--segment_threshold" "-s"
        @arghelp "Threshold for image segmentation algorithm (unseeded region growing). Used to determine mean background value."

        @argumentflag colour "--preserve_colour"
        @arghelp "Skips morphological filtering to preserve colour of ink. Warning: less performant than default."

        @positionalrequired String input "input_file"
        @arghelp "Path to the input file."

        @positionaldefault String "result.png" output "output_file" 
        @arghelp "Path to the output file."
    end
    return args
end

function main(ARGS)
    args = parse_args(ARGS)
    img = load(args.input)
    result = extract!(img; difference=args.difference, threshold=args.segment_threshold, colour=args.colour)
    save(args.output, result)
    println("Saved ink to $(args.output).")
    return 0
end
@main
