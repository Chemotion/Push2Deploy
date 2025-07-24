export function useWhiteList() {
  const allowedOrigins = []
  const isFetchAllowedOriginsPending = false
  return {
    allowedOrigins,
    isFetchAllowedOriginsPending,
  };
}
