class ConnectivityStore {
  isOnline = $state(navigator.onLine);
}

const connectivityStore = new ConnectivityStore();

export default connectivityStore;
