using Pkg; Pkg.activate(".")
using ArgMacros

function main()
    @inlinearguments begin
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
    img = load(input)
    result = extract!(img; difference=difference, threshold=segment_threshold, colour=colour)
    save(output, result)
    println("Saved ink to $output.")
end

include("Cursive.jl")
using .Cursive
main()
