#!/usr/bin/env bash
# d07-forms.sh — Scan form handling patterns
source "$(dirname "$0")/../lib/common.sh"

echo "# D07 — FORMS"
echo ""

section "Form Libraries"
echo "  react-hook-form: $(src_count_files "from ['\"]react-hook-form|useForm")"
echo "  useFormState:    $(src_count_matches 'useFormState')"
echo "  useFormContext:  $(src_count_matches 'useFormContext')"
echo ""

section "Validation"
echo "  Zod schemas:     $(src_count_files "from ['\"]zod['\"]|z\.\(object\|string\|number\)")"
echo "  Zod resolvers:   $(src_count_files 'zodResolver')"
echo "  yup schemas:     $(src_count_files "from ['\"]yup['\"]")"
echo ""

section "shadcn Form Component"
echo "  <Form> usage:      $(src_count_matches '<Form[\s>]')"
echo "  <FormField>:       $(src_count_matches '<FormField')"
echo "  <FormItem>:        $(src_count_matches '<FormItem')"
echo "  <FormMessage>:     $(src_count_matches '<FormMessage')"
echo "  Raw <input>:       $(src_count_matches '<input[\s>]')"
echo "  shadcn <Input>:    $(src_count_matches '<Input[\s>]')"
echo ""

section "Error Messages"
echo "  Error display:     $(src_count_matches 'error.*message\|formState.*errors\|FieldError')"
echo "  Inline errors:     $(src_count_matches 'text-red\|text-destructive\|error-message')"
echo ""

section "Input Types & Attributes"
echo "  type=email:        $(src_count_matches 'type=.email')"
echo "  type=tel:          $(src_count_matches 'type=.tel')"
echo "  type=url:          $(src_count_matches 'type=.url')"
echo "  type=password:     $(src_count_matches 'type=.password')"
echo "  autocomplete:      $(src_count_matches 'autoComplete=')"
echo "  required attr:     $(src_count_matches '\brequired[\s>=]')"
echo ""

section "Multi-Step Forms"
echo "  Step/wizard patterns: $(src_count_files 'step.*form\|FormStep\|wizard\|multi.step')"
echo ""
