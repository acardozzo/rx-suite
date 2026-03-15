#!/usr/bin/env bash
# D1: Identity & Access
# M1.1 Auth | M1.2 RBAC | M1.3 Sessions | M1.4 Users
source "$(dirname "$0")/../lib/common.sh"

echo "## D1: IDENTITY & ACCESS"
echo ""

# M1.1: Authentication
section "M1.1: Authentication"
e=0
for lib in next-auth @auth/core lucia clerk @clerk/nextjs supabase/auth passport firebase-auth auth0 @auth0 keycloak better-auth; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
has_route "login\|signin\|sign-in" && echo "  route: login" && ((e++))
has_route "signup\|register\|sign-up" && echo "  route: signup" && ((e++))
has_route "forgot-password\|reset-password" && echo "  route: password-reset" && ((e++))
c=$(src_count "auth.*middleware\|withAuth\|requireAuth\|isAuthenticated\|@UseGuards")
[ "$c" -gt 0 ] && echo "  middleware: $c files" && ((e++))
c=$(src_count "oauth\|google.*provider\|github.*provider\|social.*login")
[ "$c" -gt 0 ] && echo "  social-oauth: $c files" && ((e++))
component_score "Auth" "$e" 1 3 5 7 | tail -1 > /dev/null
echo "  SCORE: $(component_score "Auth" "$e" 1 3 5 7 | head -1)"
echo ""

# M1.2: RBAC
section "M1.2: Role-Based Access Control"
e=0
c=$(src_count "role.*=.*['\"]admin\|role.*=.*['\"]user\|RoleEnum\|UserRole")
[ "$c" -gt 0 ] && echo "  role-defs: $c files" && ((e++))
c=$(src_count "permission.*check\|canAccess\|hasPermission\|@Roles\|@Authorize")
[ "$c" -gt 0 ] && echo "  perm-checks: $c files" && ((e++))
c=$(src_count "guard\|policy.*file\|@CanActivate\|ability\|casl")
[ "$c" -gt 0 ] && echo "  guards/policies: $c files" && ((e++))
has_dep "casl" || has_dep "@casl" && echo "  dep: casl" && ((e++))
echo "  SCORE: $(component_score "RBAC" "$e" 1 2 3 4 | head -1)"
echo ""

# M1.3: Sessions
section "M1.3: Session Management"
e=0
c=$(src_count "session.*config\|sessionOptions\|express-session\|iron-session")
[ "$c" -gt 0 ] && echo "  session-config: $c files" && ((e++))
c=$(src_count "refresh.*token\|token.*refresh\|rotateToken")
[ "$c" -gt 0 ] && echo "  token-refresh: $c files" && ((e++))
c=$(src_count "cookie.*set\|setCookie\|httpOnly\|sameSite\|secure.*cookie")
[ "$c" -gt 0 ] && echo "  cookie-settings: $c files" && ((e++))
c=$(src_count "device.*track\|user.*agent.*log\|activeSession")
[ "$c" -gt 0 ] && echo "  device-tracking: $c files" && ((e++))
echo "  SCORE: $(component_score "Sessions" "$e" 1 2 3 4 | head -1)"
echo ""

# M1.4: User Management
section "M1.4: User Management"
e=0
has_file "user*.prisma" || has_file "user*.schema*" && echo "  user-model" && ((e++))
c=$(src_count "user.*model\|User.*Schema\|create.*user\|UserEntity\|users.*table")
[ "$c" -gt 0 ] && echo "  user-schema: $c files" && ((e++))
has_route "invite\|invitation" && echo "  route: invite" && ((e++))
has_route "profile\|account\|settings" && echo "  route: profile" && ((e++))
c=$(src_count "avatar\|profile.*image\|uploadPhoto")
[ "$c" -gt 0 ] && echo "  avatar: $c files" && ((e++))
echo "  SCORE: $(component_score "Users" "$e" 1 2 3 5 | head -1)"
echo ""
