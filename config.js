// Supabase connection for Shred Log.
// The anon key is meant to be public: row-level security in supabase/schema.sql
// means only emails on the members list can read or write any data.
window.SHRED_CONFIG = {
  supabaseUrl: "",      // e.g. https://abcdefgh.supabase.co
  supabaseAnonKey: ""   // Project Settings → API → anon public
};
