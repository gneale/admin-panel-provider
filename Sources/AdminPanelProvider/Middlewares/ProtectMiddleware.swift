import HTTP
import Flash
import Authentication

/// Redirects unauthenticated requests to a supplied path.
public final class ProtectMiddleware: Middleware {
    public func respond(to req: Request, chainingTo next: Responder) throws -> Response {
        do {
            if let user = req.auth.authenticated(AdminPanelUser.self), user.shouldResetPassword {
                let redirectPath = "/admin/backend/users/\(user.id?.string ?? "0")/edit"

                if req.uri.path != redirectPath && req.uri.path.replacingOccurrences(of: "/", with: "") != redirectPath.replacingOccurrences(of: "/", with: "") {
                    return redirect(redirectPath).flash(.error, "Please update your password")
                }
            }

            return try next.respond(to: req)
        } catch is AuthenticationError {
            return redirect("/admin/login" + "?next=\(req.uri.path)")
        }
    }
}
