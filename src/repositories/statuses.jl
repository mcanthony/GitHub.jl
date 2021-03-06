###############
# StatusState #
###############

immutable StatusState
    name::ASCIIString
end

Base.(:(==))(a::StatusState, b::StatusState) = a.name == b.name

const PENDING = StatusState("pending")
const ERROR = StatusState("error")
const FAILURE = StatusState("failure")
const SUCCESS = StatusState("success")

##########
# Status #
##########

"""
The `GitHub.Status` type represents a Github Status. A `GitHub.Status` has the following constructor:

    GitHub.Status(state::StatusState;
                  description::AbstractString="",
                  context::AbstractString="default",
                  target_url::AbstractString="")

...where the `state` argument must be one of following values:

- `GitHub.PENDING`
- `GitHub.SUCCESS`
- `GitHub.FAILURE`
- `GitHub.ERROR`
"""
immutable Status
    state::StatusState
    description::AbstractString
    context::AbstractString
    target_url::AbstractString
    function Status(state::StatusState;
                    description::AbstractString="",
                    context::AbstractString="default",
                    target_url::AbstractString="")
        return new(state, description, context, target_url)
    end
end

function Base.Dict(status::Status)
    return Dict(
        "state" => status.state.name,
        "target_url" => status.target_url,
        "description" => status.description,
        "context" => status.context
    )
end

function post_status(owner::AbstractString, repo::AbstractString,
                     sha::AbstractString, status::Status;
                     auth = AnonymousAuth(), headers = Dict())
    authenticate_headers!(headers, auth)
    uri = api_uri("/repos/$owner/$repo/statuses/$sha")
    Requests.post(uri; json=Dict(status), headers=headers)
    return status
end

function post_status(owner::AbstractString, repo::AbstractString,
                     sha::AbstractString, state::AbstractString;
                     auth = AnonymousAuth(), headers = Dict(), options...)
    return post_status(owner, repo, sha, Status(state, options...),
                       auth = auth, headers = headers)
end
