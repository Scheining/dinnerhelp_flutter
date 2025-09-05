-- Deploy archive and delete functionality for messages
-- Run this in Supabase SQL Editor
-- Date: 2025-01-05

-- Add archive/delete columns to inquiries table
ALTER TABLE public.inquiries 
ADD COLUMN IF NOT EXISTS is_archived BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS archived_by UUID REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES auth.users(id);

-- Add archive/delete columns to individual inquiry messages
ALTER TABLE public.inquiry_messages
ADD COLUMN IF NOT EXISTS is_archived BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false;

-- Add archive/delete columns to booking chat messages
ALTER TABLE public.chat_messages
ADD COLUMN IF NOT EXISTS is_archived BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_inquiries_not_deleted 
ON public.inquiries(is_deleted) 
WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_inquiries_archived 
ON public.inquiries(is_archived, is_deleted) 
WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_inquiry_messages_not_deleted 
ON public.inquiry_messages(inquiry_id, is_deleted) 
WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_chat_messages_not_deleted 
ON public.chat_messages(booking_id, is_deleted) 
WHERE is_deleted = false;

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS archive_inquiry_conversation(UUID, UUID);
DROP FUNCTION IF EXISTS unarchive_inquiry_conversation(UUID, UUID);
DROP FUNCTION IF EXISTS delete_inquiry_conversation(UUID, UUID);
DROP FUNCTION IF EXISTS archive_booking_chat(UUID, UUID);
DROP FUNCTION IF EXISTS delete_booking_chat(UUID, UUID);

-- Create function to archive an inquiry conversation
CREATE OR REPLACE FUNCTION archive_inquiry_conversation(
  p_inquiry_id UUID,
  p_user_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if user has permission (must be part of the conversation)
  IF NOT EXISTS (
    SELECT 1 FROM inquiries 
    WHERE id = p_inquiry_id 
    AND (user_id = p_user_id OR chef_id = p_user_id)
  ) THEN
    RAISE EXCEPTION 'Unauthorized: User is not part of this conversation';
  END IF;

  -- Archive the inquiry
  UPDATE inquiries
  SET 
    is_archived = true,
    archived_at = NOW(),
    archived_by = p_user_id,
    updated_at = NOW()
  WHERE id = p_inquiry_id
  AND is_deleted = false;

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to unarchive an inquiry conversation
CREATE OR REPLACE FUNCTION unarchive_inquiry_conversation(
  p_inquiry_id UUID,
  p_user_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if user has permission
  IF NOT EXISTS (
    SELECT 1 FROM inquiries 
    WHERE id = p_inquiry_id 
    AND (user_id = p_user_id OR chef_id = p_user_id)
  ) THEN
    RAISE EXCEPTION 'Unauthorized: User is not part of this conversation';
  END IF;

  -- Unarchive the inquiry
  UPDATE inquiries
  SET 
    is_archived = false,
    archived_at = NULL,
    archived_by = NULL,
    updated_at = NOW()
  WHERE id = p_inquiry_id;

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to soft delete an inquiry conversation
CREATE OR REPLACE FUNCTION delete_inquiry_conversation(
  p_inquiry_id UUID,
  p_user_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if user has permission
  IF NOT EXISTS (
    SELECT 1 FROM inquiries 
    WHERE id = p_inquiry_id 
    AND (user_id = p_user_id OR chef_id = p_user_id)
  ) THEN
    RAISE EXCEPTION 'Unauthorized: User is not part of this conversation';
  END IF;

  -- Soft delete the inquiry
  UPDATE inquiries
  SET 
    is_deleted = true,
    deleted_at = NOW(),
    deleted_by = p_user_id,
    updated_at = NOW()
  WHERE id = p_inquiry_id;

  -- Also soft delete all messages in the conversation
  UPDATE inquiry_messages
  SET is_deleted = true
  WHERE inquiry_id = p_inquiry_id;

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to archive booking chat
CREATE OR REPLACE FUNCTION archive_booking_chat(
  p_booking_id UUID,
  p_user_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if user has permission (must be part of the booking)
  IF NOT EXISTS (
    SELECT 1 FROM bookings 
    WHERE id = p_booking_id 
    AND (user_id = p_user_id OR chef_id = p_user_id)
  ) THEN
    RAISE EXCEPTION 'Unauthorized: User is not part of this booking';
  END IF;

  -- Archive all messages for this booking from the user's perspective
  UPDATE chat_messages
  SET 
    is_archived = true,
    archived_at = NOW()
  WHERE booking_id = p_booking_id
  AND (sender_id = p_user_id OR receiver_id = p_user_id);

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to soft delete booking chat
CREATE OR REPLACE FUNCTION delete_booking_chat(
  p_booking_id UUID,
  p_user_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  v_booking_status TEXT;
BEGIN
  -- Check if user has permission and get booking status
  SELECT status INTO v_booking_status
  FROM bookings 
  WHERE id = p_booking_id 
  AND (user_id = p_user_id OR chef_id = p_user_id);

  IF v_booking_status IS NULL THEN
    RAISE EXCEPTION 'Unauthorized: User is not part of this booking';
  END IF;

  -- Prevent deletion of active bookings
  IF v_booking_status IN ('pending', 'accepted', 'confirmed', 'in_progress') THEN
    RAISE EXCEPTION 'Cannot delete chat for active booking';
  END IF;

  -- Soft delete all messages for this booking from the user's perspective
  UPDATE chat_messages
  SET 
    is_deleted = true,
    deleted_at = NOW()
  WHERE booking_id = p_booking_id
  AND (sender_id = p_user_id OR receiver_id = p_user_id);

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION archive_inquiry_conversation TO authenticated;
GRANT EXECUTE ON FUNCTION unarchive_inquiry_conversation TO authenticated;
GRANT EXECUTE ON FUNCTION delete_inquiry_conversation TO authenticated;
GRANT EXECUTE ON FUNCTION archive_booking_chat TO authenticated;
GRANT EXECUTE ON FUNCTION delete_booking_chat TO authenticated;

-- Verify the functions were created
SELECT 
  proname AS function_name,
  pg_get_function_identity_arguments(oid) AS arguments
FROM pg_proc
WHERE proname IN (
  'archive_inquiry_conversation',
  'unarchive_inquiry_conversation', 
  'delete_inquiry_conversation',
  'archive_booking_chat',
  'delete_booking_chat'
);

-- Check if columns were added successfully
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'inquiries' 
  AND column_name IN ('is_archived', 'is_deleted', 'archived_at', 'deleted_at')
ORDER BY ordinal_position;