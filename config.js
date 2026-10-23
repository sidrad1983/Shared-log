// Supabase connection for Shred Log.
// The anon key is meant to be public: row-level security in supabase/schema.sql
// means only emails on the members list can read or write any data.
window.SHRED_CONFIG = {
  supabaseUrl: "https://boxicgdewxmlxkidgloc.supabase.co",
  supabaseAnonKey: "sb_publishable_kv7lBlnq3WIjkVfhNApFcQ_4-QsSfJ4"   // publishable key, safe in public code
};
