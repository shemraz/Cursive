module Cursive

using ImageCore, FileIO, ImageMorphology, ImageSegmentation, FixedPointNumbers, ArgMacros


function sample(img::AbstractMatrix{RGB{N0f8}}, threshold::Float64)::RGB{N0f8}
    seg = unseeded_region_growing(img, threshold)
    return seg.segment_means[1]
end

function extract!(
    img::AbstractMatrix{RGB{N0f8}};
    difference::Float64,
    threshold::Float64,
    colour::Bool = false
)::AbstractMatrix{RGBA{N0f8}}
    if colour == false
        apply_filter!(img)
    end
    σ = sample(img, threshold)
    result = map(img) do px
        if colordiff(px, σ) < difference
            RGBA(0, 0, 0, 0)
        else
            RGBA(px)
        end
    end
    return result
end

function apply_filter!(img::AbstractMatrix{RGB{N0f8}})::AbstractMatrix{RGB{N0f8}}
    img .= Gray.(img) |> opening
end

function (@main)()
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

end # module Cursive
