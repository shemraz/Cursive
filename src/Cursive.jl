module Cursive

using ImageCore, ImageMorphology
using FileIO
using Chain

function ink(input::String; sample::Vector{Int64} = [255,255,255], distance::Float64 = 12.5, filter::Bool = false)
    img = load(input)
    if filter == true
        # img = RGBA.(apply_filter(load(input)))
        apply_filter!(img)
    end
    img_rgba = RGBA.(img)
    sample_rgba = @chain (sample ./ 255) RGBA(_..., 1)
    result = map(img_rgba) do px
        if colordiff(px, sample_rgba) < distance
            RGBA(0, 0, 0, 0)
        else
            px
        end
    end
    save("test/output.png", result)
end

function apply_filter(img::Matrix{ColorTypes.RGB{FixedPointNumbers.N0f8}})::Matrix{ColorTypes.Gray{FixedPointNumbers.N0f8}}
    @chain img begin
        @. Gray
        opening
    end
end

function apply_filter!(img::Matrix{ColorTypes.RGB{FixedPointNumbers.N0f8}})::Matrix{ColorTypes.Gray{FixedPointNumbers.N0f8}}
    img .= Gray.(img) |> opening
end

export ink

end # module Cursive
