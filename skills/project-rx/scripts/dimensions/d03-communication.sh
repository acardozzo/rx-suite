#!/usr/bin/env bash
# D3: Communication & Notifications
# M3.1 Email | M3.2 Realtime | M3.3 Push | M3.4 Webhooks
source "$(dirname "$0")/../lib/common.sh"

echo "## D3: COMMUNICATION & NOTIFICATIONS"
echo ""

# M3.1: Email
section "M3.1: Email"
e=0
for lib in nodemailer resend @sendgrid/mail postmark @aws-sdk/client-ses react-email @react-email; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
has_dir "emails" || has_dir "email-templates" && echo "  templates-dir" && ((e++))
c=$(src_count "sendEmail\|sendMail\|transactional.*email\|email.*template")
[ "$c" -gt 0 ] && echo "  send-calls: $c files" && ((e++))
has_env "SMTP\|RESEND\|SENDGRID\|POSTMARK\|SES_" && echo "  email-env" && ((e++))
echo "  SCORE: $(component_score "Email" "$e" 1 2 4 6 | head -1)"
echo ""

# M3.2: Realtime
section "M3.2: Realtime"
e=0
for lib in socket.io ws pusher ably @supabase/realtime-js @ably-labs liveblocks; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
c=$(src_count "WebSocket\|text/event-stream\|EventSource\|ServerSentEvent\|useChannel")
[ "$c" -gt 0 ] && echo "  ws/sse-usage: $c files" && ((e++))
c=$(src_count "subscribe\|onMessage\|broadcast\|emit.*event")
[ "$c" -gt 0 ] && echo "  pub/sub: $c files" && ((e++))
has_env "PUSHER\|ABLY\|WS_" && echo "  realtime-env" && ((e++))
echo "  SCORE: $(component_score "Realtime" "$e" 1 2 3 5 | head -1)"
echo ""

# M3.3: Push Notifications
section "M3.3: Push Notifications"
e=0
for lib in web-push firebase-messaging expo-notifications @firebase/messaging onesignal; do
  has_dep "$lib" && echo "  dep: $lib" && ((e++))
done
has_file "sw.js" || has_file "service-worker*" && echo "  service-worker" && ((e++))
has_route "push\|subscription\|notification" && echo "  route: push" && ((e++))
c=$(src_count "pushSubscription\|Notification\.requestPermission\|messaging\.getToken")
[ "$c" -gt 0 ] && echo "  push-impl: $c files" && ((e++))
echo "  SCORE: $(component_score "Push" "$e" 1 2 3 4 | head -1)"
echo ""

# M3.4: Webhooks
section "M3.4: Webhooks"
e=0
has_route "webhook" && echo "  route: webhook" && ((e++))
c=$(src_count "webhook.*signature\|verify.*webhook\|constructEvent\|svix")
[ "$c" -gt 0 ] && echo "  sig-verify: $c files" && ((e++))
c=$(src_count "webhook.*event\|webhook.*type\|event.*type.*=")
[ "$c" -gt 0 ] && echo "  event-types: $c files" && ((e++))
c=$(src_count "webhook.*retry\|webhook.*deliver\|outbound.*hook\|sendWebhook")
[ "$c" -gt 0 ] && echo "  outbound/retry: $c files" && ((e++))
has_dep "svix" && echo "  dep: svix" && ((e++))
echo "  SCORE: $(component_score "Webhooks" "$e" 1 2 3 5 | head -1)"
echo ""
