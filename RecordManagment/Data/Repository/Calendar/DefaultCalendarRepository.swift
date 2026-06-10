import Foundation
import Alamofire

struct DefaultCalendarRepository: CalendarRepository {
    private let manager: IntergrationManager
    private let keyChain: KeyChainManager
    
    init(
        manager: IntergrationManager,
        keyChain: KeyChainManager
    ) {
        self.manager = manager
        self.keyChain = keyChain
    }
    
    func fetchTotalDays(for date: Date, type: DropDownFilter) async throws(CalendarError) -> CalendarRecord {
        guard
            let year = Calendar.current.dateComponents([.year], from: date).year,
            let month = Calendar.current.dateComponents([.month], from: date).month
        else { throw .inVaildDate(date: date) }
        
        let urlString: String = DomainManager.Path.totalCalendar(year: year, month: month).urlString
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        guard var components = URLComponents(string: urlString) else {
            throw .inVaildURL(url: urlString)
        }

        if type != .all {
            components.queryItems = [URLQueryItem(name: "type", value: type.name)]
        }
        guard let url = components.url else { throw .inVaildURL(url: urlString) }
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(CalendarRecord.self).value
                return response
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .fetchTotalCalendarFailed
        }
    }
    
    func fetchDateDetailRecords(for date: Date) async throws(CalendarError) -> ([IntergrationRecord], [ScheduleDetail]) {
        let selectedDate = Date.onBoardingFormet(date)
        let url = DomainManager.Path.detailRecords(date: selectedDate).url
        guard let url = url else { throw .inVaildDate(date: date) }
        
        guard let accessToken = await keyChain.read(account: "accessToken") else {
            throw .notToken
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let task = AF.request(
            url,
            method: .get,
            headers: headers
        )
        
        do {
            let result = try await manager.withTokenRetry {
                let response = try await task.serializingDecodable(CalendarDetail.self).value
                if let data = response.data {
                    let records = data.records
                    let schedules = data.schedules
                    return (records, schedules)
                } else {
                    return ([], [])
                }
            }
            return result
        } catch {
            Log.error(error.localizedDescription)
            throw .unknown(error)
        }        
    }
}
