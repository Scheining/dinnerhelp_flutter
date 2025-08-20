# DinnerHelp Beta App Description

## Beta App Description (For TestFlight)

Welcome to DinnerHelp Beta! 

DinnerHelp connects you with professional chefs who bring restaurant-quality dining experiences directly to your home. Whether you're hosting a special dinner party, celebrating an occasion, or simply want to enjoy gourmet cuisine without leaving home, our platform makes it easy to book talented local chefs.

### What to Test in This Beta:

**Core Features:**
- Browse and discover professional chefs in your area
- View detailed chef profiles, specialties, and pricing
- Book chefs for your preferred date and time
- Real-time availability checking
- Secure payment processing with automatic capture upon service completion
- In-app messaging with your booked chef
- Push notifications for booking updates
- Review and rate your dining experience

**New in This Beta:**
- Enhanced booking flow with improved date/time selection
- Automatic payment processing (funds reserved on booking, captured on completion)
- Smart refund policy (48-hour full refund, 24-hour partial refund)
- Chef approval system ensuring quality standards
- Improved notification system for booking status updates
- Enhanced search and filtering by cuisine, dietary requirements, and occasions

### How to Test:

1. **Sign Up/Login**: Create a new account or use the test credentials provided below
2. **Browse Chefs**: Explore chef profiles and their specialties
3. **Make a Booking**: Select a chef, choose your date/time, and specify guest count
4. **Payment**: Use Stripe test cards (4242 4242 4242 4242) for testing payments
5. **Communication**: Test the messaging feature with your booked chef
6. **Notifications**: Ensure you allow push notifications to test booking updates

### Test Scenarios to Try:

- Book a chef for different occasions (dinner party, birthday, anniversary)
- Test the cancellation policy (try cancelling at different time intervals)
- Filter chefs by cuisine type (Danish, Italian, Asian, etc.)
- Search for chefs with specific dietary specialties (vegan, gluten-free)
- Test booking during peak times and holidays
- Try the favorite chefs feature
- Test the review system after a completed booking

### Known Issues in Beta:

- Some UI elements may require refinement
- Chef availability calendar is being optimized
- Gallery images loading performance improvements in progress

### Feedback Requested:

We're particularly interested in feedback about:
- The booking flow ease of use
- Payment process clarity
- Chef search and filtering effectiveness
- Notification timing and relevance
- Overall app performance and stability

### Privacy & Data:

This beta version connects to our staging environment. While payments are processed through Stripe's test mode, please do not enter real payment information beyond the test cards provided.

---

## Test Credentials (For Testers)

### Test User Account:
- Email: testuser@dinnerhelp.dk
- Password: TestUser123!

### Test Chef Account:
- Email: testchef@dinnerhelp.dk
- Password: TestChef123!

### Test Payment Cards (Stripe Test Mode):
- Success: 4242 4242 4242 4242
- Requires Authentication: 4000 0025 0000 3155
- Decline: 4000 0000 0000 9995

Use any future expiry date and any 3-digit CVC.

### Test Booking Scenarios:

1. **Standard Booking Flow**:
   - Search for a chef
   - Select date at least 48 hours in advance
   - Complete payment
   - Receive confirmation

2. **Cancellation Testing**:
   - Create a booking
   - Test cancellation > 48 hours (full refund)
   - Test cancellation 24-48 hours (50% refund)
   - Test cancellation < 24 hours (no refund)

3. **Chef Communication**:
   - After booking, test the chat feature
   - Send messages about dietary requirements
   - Discuss menu customization

---

## Contact & Support

For beta testing support or to report issues:
- Email: beta@dinnerhelp.dk
- Include your device model and iOS version
- Screenshots of any issues are helpful

Thank you for helping us make DinnerHelp better! Your feedback is invaluable in creating the best possible experience for food lovers and professional chefs.

---

## Version Information

- Version: 1.0.0
- Build: 1
- Environment: Beta/Staging
- Minimum iOS: 13.0