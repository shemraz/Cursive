module Cursive

using ImageCore, ImageMorphology, ImageSegmentation
using FileIO, FixedPointNumbers

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

export load, extract!

end # module Cursive
