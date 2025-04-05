#functions

# Function to process each id
trim_tracks <- function(df, tagmeta, bird) {
  # Filter data for the specific id
  bird_df <- df %>% filter(id == bird)
  print(bird)
  
  # Get deploy and retrieve times from tagmeta
  meta <- tagmeta %>%
    filter(id == bird) %>%
    dplyr::select(deploy1, retrieve1)
  
  # Trim data based on deploy/retrieve times
  if (nrow(meta) == 0) {
    return(NULL)
    print("no metadata found")
  } else {
    trim_df <- bird_df %>%
      filter(datetime >= meta$deploy1 & datetime <= meta$retrieve1)
    print('metadata found')
  }
  
  return(trim_df)
}
