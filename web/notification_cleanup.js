// Delivered browser notifications belong to this origin, not the next login.
window.clearSellerNotifications = async function () {
  if (!('serviceWorker' in navigator)) return;
  const registrations = await navigator.serviceWorker.getRegistrations();
  await Promise.all(registrations.map(async (registration) => {
    const notifications = await registration.getNotifications();
    notifications.forEach((notification) => notification.close());
  }));
};
