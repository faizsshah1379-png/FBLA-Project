export type PlannerUser = {
  id: string;
  name: string;
  role: string;
  preferredTheme: string;
  totalEvents: number;
};

export const plannerUser: PlannerUser = {
  id: 'U-1302',
  name: 'Jordan Lee',
  role: 'Event Organizer',
  preferredTheme: 'Modern Garden',
  totalEvents: 7
};

export const dashboardHighlights = [
  { id: '1', title: 'Spring Gala planning status: 78%', tag: 'On track for April 14' },
  { id: '2', title: 'Catering quote approved from Blue Orchid', tag: 'Budget-safe option selected' },
  { id: '3', title: 'Venue walkthrough scheduled', tag: 'March 9 at 5:30 PM' },
  { id: '4', title: 'Checklist update: 42/56 tasks complete', tag: '14 tasks left' }
];

export const partyEvents = [
  { id: '1', title: 'Birthday Dinner', date: 'Mar 18', time: '6:30 PM', location: 'The Grove Hall' },
  { id: '2', title: 'Graduation Party', date: 'Apr 14', time: '3:00 PM', location: 'Sunset Pavilion' },
  { id: '3', title: 'Office Mixer', date: 'Apr 28', time: '5:30 PM', location: 'Rooftop Lounge' },
  { id: '4', title: 'Baby Shower', date: 'May 9', time: '1:00 PM', location: 'Lakeview Venue' },
  { id: '5', title: 'Anniversary Reception', date: 'May 20', time: '7:00 PM', location: 'Crystal Ballroom' },
  { id: '6', title: 'Summer BBQ', date: 'Jun 8', time: '2:00 PM', location: 'City Park' }
];

export const guestGroups = [
  { id: '1', name: 'Family', invited: 36, rsvpYes: 28, rsvpNo: 4, pending: 4 },
  { id: '2', name: 'Friends', invited: 48, rsvpYes: 33, rsvpNo: 5, pending: 10 },
  { id: '3', name: 'Coworkers', invited: 24, rsvpYes: 17, rsvpNo: 2, pending: 5 },
  { id: '4', name: 'VIP Guests', invited: 12, rsvpYes: 9, rsvpNo: 1, pending: 2 }
];

export const sampleGuests = [
  { id: '1', name: 'Ari Thompson', group: 'Family', meal: 'Vegetarian', status: 'Confirmed' },
  { id: '2', name: 'Noah Patel', group: 'Friends', meal: 'Standard', status: 'Confirmed' },
  { id: '3', name: 'Maya Chen', group: 'Coworkers', meal: 'Gluten-Free', status: 'Pending' },
  { id: '4', name: 'Luis Romero', group: 'VIP Guests', meal: 'Standard', status: 'Confirmed' },
  { id: '5', name: 'Eden Brooks', group: 'Friends', meal: 'Vegan', status: 'Declined' },
  { id: '6', name: 'Sana Yusuf', group: 'Family', meal: 'Standard', status: 'Confirmed' }
];

export const budgetSummary = {
  totalBudget: 12000,
  spent: 8345,
  remaining: 3655
};

export const budgetItems = [
  { id: '1', category: 'Venue', planned: 4200, spent: 3900 },
  { id: '2', category: 'Catering', planned: 3000, spent: 2450 },
  { id: '3', category: 'Decor', planned: 1500, spent: 980 },
  { id: '4', category: 'Entertainment', planned: 1800, spent: 725 },
  { id: '5', category: 'Photography', planned: 1000, spent: 290 },
  { id: '6', category: 'Invitations', planned: 500, spent: 0 }
];

export const vendors = [
  { id: '1', name: 'Blue Orchid Catering', type: 'Catering', rating: '4.8', notes: 'Custom menu + allergy labeling' },
  { id: '2', name: 'Pulse DJ Co.', type: 'Music', rating: '4.6', notes: 'Includes MC + lighting package' },
  { id: '3', name: 'Everlight Photo', type: 'Photography', rating: '4.9', notes: '8-hour package with highlights reel' },
  { id: '4', name: 'Petal & Pine', type: 'Decor', rating: '4.7', notes: 'Floral and table styling bundle' },
  { id: '5', name: 'Skyline Events', type: 'Venue', rating: '4.5', notes: 'Rooftop indoor/outdoor access' },
  { id: '6', name: 'PrintMint Studio', type: 'Invitations', rating: '4.7', notes: 'Fast turnaround for premium cards' }
];

export const inspirationBoards = [
  { id: '1', theme: 'Modern Garden', detail: 'Soft green, white florals, natural textures', source: 'Pinterest Board' },
  { id: '2', theme: 'Gold & Noir', detail: 'Bold black accents with metallic highlights', source: 'Instagram Collection' },
  { id: '3', theme: 'Coastal Celebration', detail: 'Blue palette, open-air seating, lantern lights', source: 'YouTube Playlist' },
  { id: '4', theme: 'Retro Party', detail: 'Neon signs, vinyl decor, fun photo booth props', source: 'TikTok Favorites' },
  { id: '5', theme: 'Minimal Chic', detail: 'Neutral palette and clean typography', source: 'Design Moodboard' }
];

export const reminderSettings = [
  { id: '1', name: 'Vendor payment due dates', status: 'Enabled' },
  { id: '2', name: 'Guest RSVP deadlines', status: 'Enabled' },
  { id: '3', name: 'Checklist milestone alerts', status: 'Enabled' },
  { id: '4', name: 'Day-before event reminders', status: 'Enabled' }
];
