module Cursive

using ImageCore, FileIO, ImageMorphology, ImageSegmentation, FixedPointNumbers, ArgParse

function parse_cl()::Dict{Symbol,Any}
    s = ArgParseSettings()

    @add_arg_table s begin
        "path"
            help = "Path to input image."
        "--output", "-o"
            help = "Path to output image (must be PNG)."
            arg_type = String
            default = "./result.png"
        "--difference", "-d"
            help = "Maximum difference from mean background value to remove."
            arg_type = Float64
            default = 12.5
        "--segment_threshold", "-s"
            help = "Threshold for image segmentation algorithm (unseeded region growing). Used to determine mean background value."
            arg_type = Float64
            default = 0.2
        "--preserve_colour"
            help = "Prevents morphological filtering to preserve ink colour. Warning: less performant than default setting."
            action = :store_true
    end
    return parse_args(s; as_symbols = true)
end

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

function main()
    params = parse_cl()
    img = load(params[:path])
    result = extract!(
        img; difference=params[:difference],
        threshold=params[:segment_threshold],
        colour=params[:preserve_colour]
    )
    save(params[:output], result)
end

end # module Cursive
